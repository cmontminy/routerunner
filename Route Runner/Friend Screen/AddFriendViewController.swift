//
//  AddFriendViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 5/4/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var backgroundBox: UIView!
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var resultBox: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendSkillLevel: UILabel!
    
    var friendData: UserData?
    var tableView: UITableView!
    var reloadFriends: (() -> Void)!
    
    @IBAction func onAddFriendButtonPressed(_ sender: Any) {
        addFriend()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundBox.layer.cornerRadius = 20
        resultBox.layer.cornerRadius = 20
        
        resultBox.isHidden = true
        profilePic.layer.cornerRadius = 20
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tableView.reloadData()
    }
    
    @IBAction func onSearchButtonPressed(_ sender: Any) {
        guard let query = emailField.text else {
            return
        }
        let db = Firestore.firestore()
        db.collection("users").whereField("email", isEqualTo: query).getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error in query \(err.localizedDescription)")
            } else {
                if querySnapshot!.isEmpty {
                    print("No users with this email")
                } else {
                    self.friendData = try! querySnapshot!.documents.first!.data(as: UserData.self)
                    self.showFriend()
                }
            }
        }
    }
    
    func showFriend() {
        guard let friend = friendData else {
            return
        }
        resultBox.isHidden = false
        friendName.text = "\(friend.firstName) \(friend.lastName)"
        friendSkillLevel.text = friend.experienceLevel
        friend.getImage { image in
            self.profilePic.image = image
        }
    }
    
    func addFriend() {
        guard let friend = friendData else {
            return
        }
        let db = Firestore.firestore()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                db.collection("users").document(user.uid).updateData([
                    "friends": FieldValue.arrayUnion([friend.uid])
                ])
                db.collection("users").document(friend.uid).updateData([
                    "friends": FieldValue.arrayUnion([user.uid])
                ])
                print("Added \(friend.firstName) \(friend.lastName) uid: \(friend.uid)")
                self.resultBox.isHidden = false
                self.reloadFriends()
            }
        }

    }
    
    
}
