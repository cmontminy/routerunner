//
//  HistoryViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

var runs: [RunData] = []

// Populate runs with dummy data for testing purposes
func addDummyData() {
    
    // seconds in a day, for date generation
    let day = 86400.0
    
    for i in 1...8 {
        runs.append(RunData(name: "Test \(i)",
                            image: UIImage(named: "sample\(i % 6)"),
                            date: Date(timeIntervalSinceNow: day * Double(i)),
                            distance: 4.0 + Double(i),
                            points: 5 + i,
                            time: i * 45))
    }
}



class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Identifiers
    let textCellIdentifier = "HistoryCell"
    let segueIdentifier = "HistorySegue"
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        let row = indexPath.row
        
        let run = runs[row]
        
        // Display name, distance to 1 decimal place, and the correct distance unit
        cell.runName.text = "\(run.name) - \(String(format: "%.1f", run.getDistance())) \(self.usingKilometers() ? "km" : "mi")"
        
        cell.runLocations.text = "\(run.locations.count) Locations"
        
        cell.runLocations.isHidden = true
        
        cell.runDate.text = run.getDateString()

        run.getImage { image in
            cell.runImage?.image = image
        }
        
        // Give image rounded edges
        cell.runImage?.layer.cornerRadius = 8.0
        cell.runImage?.layer.masksToBounds = true

        return cell
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRunData()
        
        // Reload to account for new runs / changed distance unit preference
        tableView.reloadData()
    }
    
    // Provide PastRun page with selected RunData
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let destination = segue.destination as? PastRunViewController,
           let runIndex = tableView.indexPathForSelectedRow?.row {
            destination.run = runs[runIndex]
        }
    }
    
    func loadRunData() {
        let db = Firestore.firestore()
        runs.removeAll()
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                db.collection("runs").whereField("uid", isEqualTo: user.uid)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let run = try! document.data(as:RunData.self)
                                run.pictureURL = (document.data()["pictureURL"] ?? "") as? String ?? ""
                                runs.append(run)
                                
                            }
                            self.tableView.reloadData()
                        }
                }
            }
        }
    }
}
