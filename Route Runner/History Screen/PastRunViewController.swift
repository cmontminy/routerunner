//
//  PastRunViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/22/22.
//

import UIKit


class PastRunViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var runImage: UIImageView!
    @IBOutlet weak var runName: UILabel!
    @IBOutlet weak var runDistance: UILabel!
    @IBOutlet weak var runPoints: UILabel!
    @IBOutlet weak var runTime: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var runPace: UILabel!
    
    // Selected run's data
    var run: RunData? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let currentRun = run!
        
        // Use placeholder if no image
        runImage.image = currentRun.image ?? UIImage(named: "dummy")
        runName.text = currentRun.name
        
        // Format distance to 1 decimal place, use correct units
        runDistance.text = "\(String(format: "%.1f", currentRun.getDistance())) \(self.usingKilometers() ? "km" : "mi")"
        
        runPoints.text = "\(currentRun.points) points"
        
        // Format seconds to always have 2 digits
        runTime.text = "\(currentRun.time / 60):\(String(format: "%02d", currentRun.time % 60))"
        
        // Display km/mi based on user preference
        paceLabel.text = self.usingKilometers() ? "Pace (km)" : "Pace (mi)"
        
        // Format seconds to always have 2 digits
        runPace.text = "\(currentRun.getPace() / 60):\(String(format: "%02d", currentRun.getPace() % 60))"
        
        // Round image corners
        runImage.layer.cornerRadius = 8.0
        runImage.layer.masksToBounds = true
    }
}
