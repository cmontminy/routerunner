//
//  FriendViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 5/3/22.
//

import UIKit

var friends: [UserData] = []

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "FriendCell"
    
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
          }
        
        cell.removeAction  = { (cell) in
            friends.remove(at: indexPath.row)
            tableView.reloadData()
          }
        
        // Use placeholder image if none provided
        cell.profilePic?.image = UIImage(named: "dummy")
        
        // Give image rounded edges
        cell.profilePic?.layer.cornerRadius = 8.0
        cell.profilePic?.layer.masksToBounds = true

        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        print("running?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
                tableView.delegate = self
        tableView.dataSource = self
        startObserving(&UserInterfaceStyleManager.shared)
        
        tableView.rowHeight = 180
        
        friends.append(UserData(firstName: "w", lastName: "q", email: "w", experienceLevel: "new", uid: "54trbfdsr"))
        
        friends.append(UserData(firstName: "e", lastName: "t", email: "w", experienceLevel: "advanced", uid: "54trbfdsr"))
    }
    
}
