//
//  RunCreationViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 4/13/22.
//

import UIKit
import MapKit
import CoreLocation

class RunCreationViewController: UIViewController {
    @IBOutlet weak var distanceField: UITextField!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var endField: UITextField!
    
    var locationManager = CLLocationManager()
    
    @IBAction func currentLocationButtonPressed () {
        guard locationManager.location != nil else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationManager.location!, completionHandler: {placemarks, error in
            if error == nil {
                self.startField.text = placemarks![0].name
            } else {
                print("CLGeocoder error: \(error!.localizedDescription)")
            }
        })
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
    }
}
