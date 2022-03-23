//
//  HistoryViewController.swift
//
//  Project: RouteRunner
//  EID: tb29668
//  Course: CS371L
//
//  Created by Truman Byrd on 3/22/22.
//

import UIKit


class PastRunViewController: UIViewController {
    @IBOutlet weak var runImage: UIImageView!
    @IBOutlet weak var runName: UILabel!
    @IBOutlet weak var runDistance: UILabel!
    @IBOutlet weak var runPoints: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var runPace: UILabel!
    
    var run: RunData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentRun = run!
        runImage.image = currentRun.image ?? UIImage(named: "dummy")
        runName.text = currentRun.name
        runDistance.text = "\(currentRun.getDistance()) \(usingKilometers() ? "km" : "mi")"
        runPoints.text = "\(currentRun.points) points"
        runTime.text = "\(currentRun.time / 60):\(String(format: "%02d", currentRun.time % 60))"
        paceLabel.text = usingKilometers() ? "Pace (km)" : "Pace (mi)"
        
        runPace.text = "\(currentRun.getPace() / 60):\(String(format: "%02d", currentRun.getPace() % 60))"
        
        runImage.layer.cornerRadius = 8.0
        runImage.layer.masksToBounds = true
    }
    
    private func usingKilometers() -> Bool {
        return UserDefaults.standard.bool(forKey:"RouteRunnerKilometerModeOn")
    }
}
