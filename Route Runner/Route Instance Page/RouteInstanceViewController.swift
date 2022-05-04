//
//  RouteInstanceViewController.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 5/3/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import CoreLocation
import MapKit

class RouteInstanceViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    
    public let metersToMiles = 0.000621371 // constant conversion from meters to miles
    public let metersToKm = 0.001 // constant conversion from meters to kilometers
    
    public var routeData: RunData! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        startButton.tintColor = hexStringToUIColor(hex: "#FF7500")
        
        if(routeData != nil && routeData.route != nil) {
            routeData.route!.calculate {response ,error in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                let directionsRoute = response.routes[0] // route data
                
                // set title to name and route distance length
                let unit = self.usingKilometers() ? " km" : " mi"
                // detemrmine unit to convert to
                let conversion = self.usingKilometers() ? self.metersToKm : self.metersToMiles
                
                // round distance to tenth
                let rDistance = round((directionsRoute.distance * conversion) * 10) / 10.0
                // get time
                let rTime: Int = Int(round(directionsRoute.expectedTravelTime / 60))
                
                // set labels to values
                self.distanceLabel.text = String(rDistance) + unit
                self.timeLabel.text = String(rTime) + " min"
                self.pointsLabel.text = "0"
                self.paceLabel.text = "0"
                self.titleLabel.text = directionsRoute.name
                                
                // add properties to routeData
                self.routeData.name = directionsRoute.name
                self.routeData.distance = rDistance
                self.routeData.time = rTime
                self.routeData.points = 0
                
                // display route on map
                self.mapView.addOverlay((directionsRoute.polyline), level: MKOverlayLevel.aboveRoads)
                
                // calculate zoom level for map
                let c1Lat: Double = self.routeData.startCoordLat ?? 0.0
                let c2Lat: Double = self.routeData.endCoordLat ?? 0.0
                let c1Long: Double = self.routeData.startCoordLong ?? 0.0
                let c2Long: Double = self.routeData.endCoordLong ?? 0.0
                
                let c1 = CLLocation(latitude: c1Lat, longitude: c1Long)
                let c2 = CLLocation(latitude: c2Lat, longitude: c2Long)
                let zoom = c1.distance(from: c2) * 1.25
                // get center location
                let location = CLLocationCoordinate2D(latitude: (c1Lat+c2Lat)*0.5, longitude: (c1Long+c2Long)*0.5)

                // Create a region and fit the map to it.
                let region = MKCoordinateRegion(center: location, latitudinalMeters: zoom, longitudinalMeters: zoom)
                self.mapView.setRegion(region, animated: false)
            }
        }
    }
    
    @IBAction func onStartButtonPressed(_ sender: Any) {
        // save route to firebase
        let db = Firestore.firestore()
        
        do {
            try db.collection("runs").addDocument(from: routeData)
            print("here")
        } catch {
            print("Error in RouteInstanceViewController: uploading route to Firestore DB")
        }
        
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

extension RouteInstanceViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)

      renderer.strokeColor = hexStringToUIColor(hex: "#FF7500")
      renderer.lineWidth = 5
    
    return renderer
  }
}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }

    if ((cString.count) != 6) {
        return UIColor.gray
    }

    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

