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
        runDistance.text = "\(currentRun.distance) mi"
        runPoints.text = "\(currentRun.points) points"
        runTime.text = "\(currentRun.time / 60):\(currentRun.time % 60)"
        runPace.text = "\(currentRun.pace / 60):\(currentRun.pace % 60)"
        
        runImage.layer.cornerRadius = 8.0
        runImage.layer.masksToBounds = true
    }
}
