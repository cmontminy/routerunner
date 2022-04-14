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
    
    var startPoint: CLPlacemark?
    var region: MKCoordinateRegion?
    var directions: MKDirections?
//    var endPoint: CLPlacemark?
    
    @IBAction func currentLocationButtonPressed() {
        guard locationManager.location != nil else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationManager.location!, completionHandler: {placemarks, error in
            if error == nil {
                self.startField.text = placemarks![0].name
                self.startPoint = placemarks![0]
//                print("Placemarks: \(placemarks!)")
            } else {
                print("CLGeocoder error: \(error!.localizedDescription)")
            }
        })
    }
    
    @IBAction func createRoute() {
        
        print("IN ACTION!")
        
        Task {
            guard startField.text != nil, endField.text != nil else {
                print("Missing parameters for route.")
                return
            }
            
            guard let start = await getPlace(startField.text!) else {
                print("Failed to create start")
                return
            }
            
            guard let end = await getPlace(endField.text!) else {
                print("Failed to create end")
                return
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: start)
            request.destination = MKMapItem(placemark: end)
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            directions = MKDirections(request: request)
            
            guard directions != nil else {
                return
            }
            
            routes.append(RunData(route: directions!))
            
            performSegue(withIdentifier:"ShowTesting", sender: nil)
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTesting" {
            let nextVC = segue.destination as! RouteTestingViewController
            nextVC.directions = directions
        }
    }
    
    // Use MKLocalSearch to find a placemark in the region based on the textQuery
    func getPlace(_ textQuery: String) async -> MKPlacemark? {
        guard region != nil else {
            print("nil region in getPlace")
            return nil
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = textQuery
        request.region = region!
        
        var returnVal: MKPlacemark? = nil
        
        
        
        let response = try? await MKLocalSearch(request: request).start()
        
        let place: MKPlacemark?

        if let firstItem = response?.mapItems.first {
        place = firstItem.placemark
        } else {
            print("Bad response, response: \(response)")
        place = nil
        }
        returnVal = place
        print("Set returnVal to \(place)")
        
        print("Returning \(returnVal)")
        return returnVal
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.requestLocation()
    }
}

extension RunCreationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated, locations: \(locations)")
        
        guard locations.last != nil else {
            return
        }
        
        let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        region = MKCoordinateRegion(center: locations.last!.coordinate, span: span)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed with error: \(error.localizedDescription)")
    }
}
