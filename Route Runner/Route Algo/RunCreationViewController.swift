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
    var newRunData: RunData?
    var curLocation: CLLocationCoordinate2D?
    
    // Fill startField with current location
    @IBAction func currentLocationButtonPressed() {
        guard locationManager.location != nil else {
            return
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(locationManager.location!, completionHandler: {placemarks, error in
            if error == nil {
                self.startField.text = placemarks![0].name
                self.startPoint = placemarks![0]
            } else {
                print("CLGeocoder error: \(error!.localizedDescription)")
            }
        })
    }
    
    // Get directions for a route based on start/endpoints
    @IBAction func createRoute() {
                
        Task {
            guard startField.text != nil, endField.text != nil else {
                print("Missing parameters for route.")
                return
            }
            
            guard var start = await getPlace(startField.text!) else {
                print("Failed to create start")
                return
            }
            
            guard let end = await getPlace(endField.text!) else {
                print("Failed to create end")
                return
            }
            
            if (curLocation != nil) {
                start = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: curLocation!.latitude, longitude: curLocation!.longitude))
            }
            
            // get lat long coords to store
            let startCoordLat = start.coordinate.latitude
            let startCoordLong = start.coordinate.longitude
            let endCoordLat = end.coordinate.latitude
            let endCoordLong = end.coordinate.longitude
            
            // Create MKDirections Request
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: start)
            request.destination = MKMapItem(placemark: end)
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            directions = MKDirections(request: request)
            
            guard directions != nil else {
                return
            }
            
            // Create a RunData object for this route
            newRunData = RunData(route: directions!)
            newRunData?.startCoordLat = startCoordLat
            newRunData?.endCoordLat = endCoordLat
            newRunData?.startCoordLong = startCoordLong
            newRunData?.endCoordLong = endCoordLong
            
            routes.append(newRunData!)
            
            // navigate to route instance screen
            performSegue(withIdentifier:"RouteInstanceIdentifier", sender: nil) // navigate
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RouteInstanceIdentifier" {
            let nextVC = segue.destination as! RouteInstanceViewController
            nextVC.routeData = newRunData // send initial route data
            nextVC.generateData = true // since this is the first instance of this route, need to generate data
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
        self.navigationController?.navigationBar.tintColor = hexStringToUIColor(hex: "#FF7500")
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
}

extension RunCreationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard locations.last != nil else {
            return
        }
        
        self.curLocation = locations.last!.coordinate
        
        // set region on first location update, needed for search
        let commonDelta: CLLocationDegrees = 25 / 111 // 1/111 = 1 latitude km
        let span = MKCoordinateSpan(latitudeDelta: commonDelta, longitudeDelta: commonDelta)
        region = MKCoordinateRegion(center: locations.last!.coordinate, span: span)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed with error: \(error.localizedDescription)")
    }
}
