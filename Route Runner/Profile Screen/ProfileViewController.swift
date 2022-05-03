//
//  ProfileViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/22/22.
//

import UIKit
import Firebase

public let dummyData = ["sample0", "sample1", "sample2", "sample3", "sample4", "sample5"]

var runList: [RunData] = []

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var numRuns: UILabel!
    @IBOutlet weak var numMiles: UILabel!
    @IBOutlet weak var numSPs: UILabel!
    @IBOutlet weak var runLabel: UILabel!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var spLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        profilePicture.image = UIImage(named: "profilepictureRR")
        startObserving(&UserInterfaceStyleManager.shared)
        
        //style profile picture
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.white.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/1
        profilePicture.clipsToBounds = true
        profilePicture.sizeToFit()
        //add shadow
        profilePicture.layer.shadowColor = UIColor.gray.cgColor
        profilePicture.layer.shadowOffset = CGSize.zero;
        profilePicture.layer.shadowOpacity = 1;
        profilePicture.layer.shadowRadius = 1.0;
        
        //customize fonts
        //let fontArr = UIFont.familyNames
        

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! ProfileCollectionViewCell
        let row = indexPath.row
//        cell.runImage?.image = UIImage(named: dummyData[row])
//        cell.runImage?.layer.cornerRadius = 8.0
//        cell.runImage?.layer.masksToBounds = true
        let run = runList[row]
        
        // Display name, distance to 1 decimal place, and the correct distance unit
        cell.runName.text = "\(run.name) - \(String(format: "%.1f", run.getDistance())) \(self.usingKilometers() ? "km" : "mi")"
        
        cell.runLocations.text = "\(run.locations.count) Locations"
        cell.runDate.text = run.getDateString()

        // Use placeholder image if none provided
        cell.runImage?.image = run.image ?? UIImage(named: "dummy")
        
        // Give image rounded edges
        cell.runImage?.layer.cornerRadius = 8.0
        cell.runImage?.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dummyData.count
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
}
