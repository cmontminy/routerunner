//
//  ProfileViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/22/22.
//

import UIKit
import Firebase
import MobileCoreServices

public let dummyData = ["sample0", "sample1", "sample2", "sample3", "sample4", "sample5"]

var runList: [RunData] = []

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //outlets
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numRuns: UILabel!
    @IBOutlet weak var numMiles: UILabel!
    @IBOutlet weak var numSPs: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var spLabel: UILabel!
    @IBOutlet weak var runnerName: UILabel!
    @IBOutlet weak var difficultyLevel: UILabel!
    
    var currentUser: UserData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    //profile picture
//        profilePicture.image = UIImage(named: "defaultProfile")
        startObserving(&UserInterfaceStyleManager.shared)
        
        //style profile picture
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = 25
        profilePicture.clipsToBounds = true
        profilePicture.sizeToFit()
        //add shadow
        profilePicture.layer.shadowColor = UIColor.gray.cgColor
        profilePicture.layer.shadowOffset = CGSize.zero;
        profilePicture.layer.shadowOpacity = 1;
        profilePicture.layer.shadowRadius = 1.0;
    }
    
    // Referenced https://medium.com/firebase-developers/how-to-upload-image-from-uiimagepickercontroller-to-cloud-storage-for-firebase-bad90f80d6a7
    @IBAction func onEditProfileButtonPressed(_ sender: Any) {
            // Must import `MobileCoreServices`
            let imageMediaType = kUTTypeImage as String

            // Define and present the `UIImagePickerController`
            let pickerController = UIImagePickerController()
            pickerController.sourceType = .photoLibrary
            pickerController.mediaTypes = [imageMediaType]
            pickerController.delegate = self
            present(pickerController, animated: true, completion: nil)
    }
    
    
    func calcNumMiles(){
        var count = 0
        var numberMiles = 0.0
        while(count < runList.count){
            numberMiles += runList[count].distance
            count += 1
        }
        numMiles.text = "\(String(format: "%.2f", numberMiles))"
    }
    
    func calcNumRuns(){
        let numberRuns = runList.count
        numRuns.text = "\(numberRuns)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRunData()
        
        // Reload to account for new runs / changed distance unit preference
        collectionView.reloadData()
        calcNumMiles()
        calcNumRuns()
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                print("Error loading user \(error.localizedDescription)")
            } else {
                guard let document = document else {
                    return
                }
                self.currentUser = try! document.data(as: UserData.self)
                self.currentUser.getImage { image in
                    self.profilePicture.image = image
                }
                self.runnerName.text = "\(self.currentUser.firstName) \(self.currentUser.lastName)"
                self.difficultyLevel.text = self.currentUser.experienceLevel
            }
        }
        
        loadProfilePic()
        
        //total number of runs
        calcNumRuns()
        
        //total number of miles
        calcNumMiles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ProfileCollectionViewCell
        let row = indexPath.row
//        cell.runImage?.image = UIImage(named: dummyData[row])
//        cell.runImage?.layer.cornerRadius = 8.0
//        cell.runImage?.layer.masksToBounds = true
        let run = runList[row]
        

        // Use placeholder image if none provided
        cell.runImage?.image = run.image ?? UIImage(named: "dummy")
        
        // Give image rounded edges
        cell.runImage?.layer.cornerRadius = 8.0
        cell.runImage?.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return runList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // add the code here to perform action on the cell
        //when run is clicked on, run detials will be shown, similar to past run in history
//        let cell = collectionView.cellForItem(at: indexPath) as? ProfileCollectionViewCell
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let layout = UICollectionViewFlowLayout()
        let containerWidth = collectionView.bounds.width
        let cellSize = (containerWidth - 45) / 3
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.collectionViewLayout = layout
        
    }
    
    func loadProfilePic() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let error = error {
                print("Error loading user \(error.localizedDescription)")
            } else {
                guard let document = document else {
                    return
                }
                try! document.data(as: UserData.self).getImage { image in
                    self.profilePicture.image = image
                }
            }
        }
    }
    
    func loadRunData() {
        let db = Firestore.firestore()
        runList.removeAll()
        guard let user = Auth.auth().currentUser else {
            return
        }
        db.collection("runs").whereField("uid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        try? runList.append(document.data(as: RunData.self))
                        print("runlist is now \(runList)")
                    }
                    self.collectionView.reloadData()
                    self.calcNumMiles()
                    self.calcNumRuns()
                }
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func uploadImage(url: URL) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let filepath = "images/\(user.uid)profile.jpg"
        
        let storageRef = Storage.storage().reference().child(filepath)
        
        let db = Firestore.firestore()
        
        let currentUploadTask = storageRef.putFile(from: url, metadata: nil) { (storageMetaData, error) in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { (url, error) in
                if let error = error  {
                    print("Error on getting download url: \(error.localizedDescription)")
                    return
                }
                print("Download url of \(filepath) is \(url!.absoluteString)")
                db.collection("users").document(user.uid).updateData(["profilePic": url!.absoluteString])
                self.loadProfilePic()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        if mediaType == kUTTypeImage {
          let imageURL = info[UIImagePickerController.InfoKey.imageURL] as! URL
            uploadImage(url: imageURL)
        }

        picker.dismiss(animated: true, completion: nil)
      }
}
