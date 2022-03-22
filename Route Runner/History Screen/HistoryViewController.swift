//
//  HistoryViewController.swift
//
//  Project: RouteRunner
//  EID: tb29668
//  Course: CS371L
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit

var runs: [RunData] = []

func addDummyData() {
    
    let day = 86400.0
    
    for i in 1...8 {
        runs.append(RunData(name: "Test \(i)",
                            locations: 4 * i,
                            image: UIImage(named: "sample\(i % 6)"),
                            date: Date(timeIntervalSinceNow: day * Double(i)),
                            distance: 4.0 + Double(i),
                            points: 5 + i,
                            time: i * 45,
                            pace: i * 32))
    }
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "HistoryCell"
    let segueIdentifier = "HistorySegue"
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! HistoryTableViewCell
        
        let row = indexPath.row
        
        let run = runs[row]
        cell.runName.text = "\(run.name) - \(run.distance) mi"
        cell.runLocations.text = "\(run.locations) Locations"
        cell.runDate.text = run.getDateString()
        
        cell.runImage?.image = run.image ?? UIImage(named: "dummy")
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
        addDummyData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let destination = segue.destination as? PastRunViewController,
           let runIndex = tableView.indexPathForSelectedRow?.row {
            destination.run = runs[runIndex]
        }
    }
}
