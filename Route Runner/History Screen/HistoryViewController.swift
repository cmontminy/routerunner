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
    
    runs.append(RunData(name: "Test 1",
                        locations: 1,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day),
                        distance: 2.1))
    runs.append(RunData(name: "Test 2",
                        locations: 7,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day * 5),
                        distance: 2.7))
    runs.append(RunData(name: "Test 3",
                        locations: 20,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day * 10),
                        distance: 23.7))
    runs.append(RunData(name: "Test 4",
                        locations: 12,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day * 1000),
                        distance: 2.1))
    runs.append(RunData(name: "Test 5",
                        locations: 9,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day * 100),
                        distance: 2.7))
    runs.append(RunData(name: "Test 6",
                        locations: 20,
                        image: nil,
                        date: Date(timeIntervalSinceNow: day * 30),
                        distance: 23.7))
    
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let textCellIdentifier = "HistoryCell"
    
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
        
        cell.runImage?.image = UIImage(named: "dummy")
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
}
