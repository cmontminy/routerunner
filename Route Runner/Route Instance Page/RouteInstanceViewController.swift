//
//  RouteInstanceViewController.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 5/3/22.
//

import UIKit

class RouteInstanceViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routeImage: UIImageView!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    public let metersToMiles = 0.000621371 // constant conversion from meters to miles
    public let metersToKm = 0.001 // constant conversion from meters to kilometers
    public let kmPerMin = 0.1 // avergae km walked per minute to estimate route time
    public let miPerMin = 0.06 // average mi walked per minute to estimate route time
    
    public var routeData: RunData! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(routeData != nil && routeData.route != nil) {
            routeData.route!.calculate {response ,error in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                let directionsRoute = response.routes[0]
                // set title to name and route distance length
                let unit = self.usingKilometers() ? " km" : " mi"
                // detemrmine unit to convert to
                let conversion = self.usingKilometers() ? self.metersToKm : self.metersToMiles
                let timePerMin = self.usingKilometers() ? self.kmPerMin : self.miPerMin
                
                // round distance to tenth and add everything to route label
                let rDistance = round((directionsRoute.distance * conversion) * 10) / 10.0
                self.titleLabel.text = self.routeData.name + "-" + String(rDistance) + unit
                self.distanceLabel.text = String(rDistance) + unit
                // get time and add to label
                let rTime = round((rDistance / timePerMin) * 10) / 10.0
                self.timeLabel.text = String(rTime) + " min"
                
                self.pointsLabel.text = "0"
                self.paceLabel.text = "0"
            }
        }
    }
    
    @IBAction func onStartButtonPressed(_ sender: Any) {
        // save route to firebase
        
        // navigate
        performSegue(withIdentifier:"RunScreenIdentifier", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RunScreenIdentifier" {
            let nextVC = segue.destination as! RunViewController
            nextVC.routeData = routeData
        }
    }
}
