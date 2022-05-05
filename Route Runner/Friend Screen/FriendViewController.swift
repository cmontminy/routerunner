//
//  FriendViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 5/3/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

var friends: [UserData] = []

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "FriendCell"
    let segueIdentifier = "AddFriend"
    let profileSegueIdentifier = "OtherProfile"
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! FriendTableViewCell
        
        let row = indexPath.row
        
        let friend = friends[row]
        
        cell.name.text = "\(friend.firstName) \(friend.lastName)"
        
        cell.skillLevel.text = friend.experienceLevel
        
        cell.runsCompleted.text = "30"
        
        cell.profileAction  = { (cell) in
            print("Viewing profile of \(friend.firstName) \(friend.lastName)")
            self.performSegue(withIdentifier: self.profileSegueIdentifier, sender: friend.uid)
          }
        
        cell.removeAction  = { (cell) in
            guard let user = Auth.auth().currentUser else {
                return
            }
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).updateData([
                "friends": FieldValue.arrayRemove([friend.uid])
            ])
            db.collection("users").document(friend.uid).updateData([
                "friends": FieldValue.arrayRemove([user.uid])
            ])
            friends.remove(at: indexPath.row)
            tableView.reloadData()
          }
        
        // Use placeholder image if none provided
//        cell.profilePic?.image = friend.picture
        friend.getImage { image in
            cell.profilePic?.image = image
        }
        
        // Give image rounded edges
        cell.profilePic?.layer.cornerRadius = 8.0
        cell.profilePic?.layer.masksToBounds = true

        return cell
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (friends.count == 0) {
            fetchFriends()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        startObserving(&UserInterfaceStyleManager.shared)
        
        tableView.rowHeight = 150
        
    }
    
    func fetchFriends() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        friends.removeAll()
        let db = Firestore.firestore()
        db.collection("users").whereField("friends", arrayContains: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        try? friends.append(document.data(as: UserData.self))
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier {
            let nextVC = segue.destination as! AddFriendViewController
            nextVC.tableView = self.tableView
            nextVC.reloadFriends = fetchFriends
        } else if segue.identifier == profileSegueIdentifier {
            let nextVC = segue.destination as! OtherProfileViewController
            nextVC.currentUID = sender as? String
            navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
}
