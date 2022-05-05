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
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var endField: UITextField!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var createButton: UIButton!
    
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
            var start: MKPlacemark?
            var end: MKPlacemark?
            
            if startField.text != "" {
                start = await getPlace(startField.text!)
            } else {
                start = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: curLocation!.latitude, longitude: curLocation!.longitude))
            }
            
            if endField.text != "" {
                end = await getPlace(endField.text!)
            } else {
                end = await searchNearby()
                if (end == nil) {
                    print("Error finding a nearby place")
                    return
                }
            }
            
            // get lat long coords to store
            let startCoordLat = start!.coordinate.latitude
            let startCoordLong = start!.coordinate.longitude
            let endCoordLat = end!.coordinate.latitude
            let endCoordLong = end!.coordinate.longitude
            
            // Create MKDirections Request
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: start!)
            request.destination = MKMapItem(placemark: end!)
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
        createButton.tintColor = hexStringToUIColor(hex: "#FF7500")
        initializeSlider()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func initializeSlider() {
        slider.layer.cornerRadius = 10
        let unit = self.usingKilometers() ? " km" : " mi"
        let initVal = slider.value
        distanceLabel.text = String((round(initVal * 10) / 10.0)) + unit
        
        slider.addTarget(self, action: #selector(onValueChanged(_:)), for: UIControl.Event.valueChanged)
    }
    
    @IBAction func onValueChanged(_ sender: Any) {
        let val = slider.value
        let unit = self.usingKilometers() ? " km" : " mi"
        distanceLabel.text = String((round(val * 10) / 10.0)) + unit
    }
    
    private func searchNearby() async -> MKPlacemark? {
        var result: MKPlacemark? = nil
        
        let conversion = usingKilometers() ? 1000 : 1609
        let maxDistance = CLLocationDistance(slider.value * Float(conversion))
        print(maxDistance)
        let region = MKCoordinateRegion(center: curLocation!, latitudinalMeters: 10000, longitudinalMeters: 10000)
        let nearbyPointsReq = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        // filter requests
        nearbyPointsReq.pointOfInterestFilter = MKPointOfInterestFilter(including: [.amusementPark, .beach, .nationalPark, .zoo, .campground, .park, .library])
        // search using request
        let search = MKLocalSearch(request: nearbyPointsReq)
        
        let response = try? await search.start()
        
        // check if there are items
        let empty = response?.mapItems.isEmpty ?? true
        if (empty) {
            return nil
        }
            
        var farthestInRange: Double = 0.0
        for item in response!.mapItems {
            let name = item.name!

            let distanceFromOrigin = CLLocation(latitude: self.curLocation!.latitude, longitude: self.curLocation!.longitude).distance(from: CLLocation(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
            
            if (distanceFromOrigin < maxDistance && distanceFromOrigin > farthestInRange) {
                farthestInRange = distanceFromOrigin
                result = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude))
            }

            print(name, distanceFromOrigin)
        }
        
        return result
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
