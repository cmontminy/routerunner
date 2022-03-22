//
//  RunViewController.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 3/21/22.
//

import UIKit
import MapKit

class RunViewController: UIViewController {

    public let METERS_TO_MILES = 0.000621371
    
    private let locationManager = CLLocationManager() // location manager
    private var startLocation: CLLocationCoordinate2D? // coordinate of start location of user
    private var currentLocation: CLLocation? // current location of user
    @IBOutlet weak var mapView: MKMapView! // Map View
    @IBOutlet weak var timeMeter: UILabel! // Label displaying elapsed time
    @IBOutlet weak var timeLabel: UILabel! // subtitle for time meter
    @IBOutlet weak var elapsedMeter: UILabel! // Label displaying elapsed distance
    @IBOutlet weak var elapsedLabel: UILabel! // subtitle for elapsed distance meter
    @IBOutlet weak var paceLabel: UILabel! // Label displaying current pace of user
    @IBOutlet weak var paceMeter: UILabel! // subtitle for pace meter
    @IBOutlet weak var routeLabel: UILabel! // route label
    @IBOutlet weak var directionLabel: UILabel! // label to display next direction user should take
    @IBOutlet weak var directionIcon: UIImageView! // icon displaying next action user should take
    
    private var totalDistanceTravelled: Double = 0 // used to store total distance user had travelled
    private var startTime = NSDate().timeIntervalSince1970 // start time stamp
    private var prevTime: Double = 0.0 // used to keep track of time since last updated for pace
    private var totalTime: Int = 0 // total time since this page loaded in minutes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices() // start location services
        // hide nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        startObserving(&UserInterfaceStyleManager.shared)
    }

    private func configureLocationServices() {
        locationManager.delegate = self
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        mapView.showsUserLocation = true
    }
    
    private func zoomToStartLocation(coordinate: CLLocationCoordinate2D) {
        // update map region and camera
        let region = MKCoordinateRegion(center:coordinate, latitudinalMeters:150,longitudinalMeters:150)
        let mapCamera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 150, pitch: 55, heading: 0)
        mapView.setRegion(region, animated: false)
        mapView.setCamera(mapCamera, animated: false)
    }
    
    private func updateCamera(coordinate: CLLocationCoordinate2D) {
        // update map region and camera
        let region = MKCoordinateRegion(center:coordinate, latitudinalMeters:150,longitudinalMeters:150)
        let mapCamera = MKMapCamera(lookingAtCenter: coordinate, fromDistance: 150, pitch: 55, heading: 0)
        mapView.setRegion(region, animated: true)
        mapView.setCamera(mapCamera, animated: true)
    }
    
    private func rotateCamera(direction: CLLocationDirection) {
        mapView.camera.heading = direction
        mapView.setCamera(mapView.camera, animated: true)
    }
    
    // function to cancel location updates
    // to run when user completes/cancels run
    private func cancelLocationUpdates(locationManager: CLLocationManager) {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // Function to present user with alert to allow them to exit the run
    // and return back to home screen.
    // Run when the red "x" button is pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Cancel Run",
            message: "Are you sure you want to cancel your current run?",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: {
            (action) in print("Navigate user home");
            self.cancelLocationUpdates(locationManager: self.locationManager);
            let storyBoard : UIStoryboard = UIStoryboard(name: "Home", bundle:nil);
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeRef") as! HomeViewController;
            self.show(nextViewController, sender:self);
        }))
        controller.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

extension RunViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else {
            return
        }
        
        if startLocation == nil {
            startLocation = latestLocation.coordinate // store start location
            zoomToStartLocation(coordinate: latestLocation.coordinate)// zoom map to new location
        } else {
            updateCamera(coordinate: latestLocation.coordinate) // update camera on map
        }
        
        // update states (distance, time, pace) and cooresponding meter labels
        if currentLocation != nil {
            // calculate distance
            let distance = latestLocation.distance(from: currentLocation!)
            totalDistanceTravelled += distance
            
            // calculate time
            let endTime = NSDate().timeIntervalSince1970
            totalTime = Int((endTime - startTime) / 60)
            
            // calculate pace
            var pace:Double = 0.0
            if prevTime != 0.0 {
                let distConverted = distance * METERS_TO_MILES
                pace = round((distConverted / ((endTime - prevTime) / 3600) ) * 10) / 10.0
            }
            prevTime = endTime
            
            // convert total distance from meters to mi/km
            let roundedMiles = round((totalDistanceTravelled * METERS_TO_MILES) * 10)/10.0
            
            // update meters
            elapsedMeter.text = String(roundedMiles)
            timeMeter.text = String(totalTime)
            paceMeter.text = String(pace)
        }
        
        currentLocation = latestLocation // update current location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        rotateCamera(direction: newHeading.magneticHeading)
   }
}

