//
//  RunViewController.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 3/21/22.
//

import UIKit
import MapKit

class RunViewController: UIViewController {

    // -- Constants --
    public let metersToMiles = 0.000621371 // constant conversion from meters to miles
    public let metersToKm = 0.001 // constant conversion from meters to kilometers
    
    // -- UI Connections --
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
    
    // -- Other Variables --
    private var totalDistanceTravelled: Double = 0 // used to store total distance user had travelled
    private var startTime = NSDate().timeIntervalSince1970 // start time stamp
    private var prevTime: Double = 0.0 // used to keep track of time since last updated for pace
    private var totalTime: Int = 0 // total time since this page loaded in minutes
    var timer = Timer() // timer to be used to update time variables
    
    // -- Functions --
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLocationServices() // start location services
        scheduledTimerWithTimeInterval() // start timer
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    // to run anytime the view appears on the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // remove back button in nav bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // to run anytime the view leaves the screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // return back button in nav bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func scheduledTimerWithTimeInterval(){
        // update times every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true, block: { _ in
            self.updateTime()
        })
    }

    // configure location services by checking authorization and starting service
    private func configureLocationServices() {
        locationManager.delegate = self
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    // start tracking user location and magnetic heading
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        mapView.showsUserLocation = true
    }
    
    // zoom map to given location
    private func zoomToCurrentLocation(coordinate: CLLocationCoordinate2D, animated: Bool) {
        // get map region and camera
        let region = MKCoordinateRegion(center:coordinate, latitudinalMeters:150,longitudinalMeters:150)
        let mapCamera = MKMapCamera(lookingAtCenter:coordinate, fromDistance:150, pitch:55, heading:0)
        // update region and camera
        mapView.setRegion(region, animated: animated)
        mapView.setCamera(mapCamera, animated: animated)
    }
    
    // rotate camera to match magnetic heading of device
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
    
    // update distance, time, and pace variables and labels
    // to run whenever user moves to a new location
    private func updateStats(latestLocation: CLLocation) {
        // calculate distance
        let distance = latestLocation.distance(from: currentLocation!)
        totalDistanceTravelled += distance
        
        // calculate time
        let endTime = NSDate().timeIntervalSince1970
        totalTime = Int((endTime - startTime) / 60)
        
        // calculate pace
        var pace:Double = 0.0
        if prevTime != 0.0 {
            let distConverted = distance * metersToMiles
            pace = round((distConverted / ((endTime - prevTime) / 3600) ) * 10) / 10.0 // round to tenths
        }
        prevTime = endTime
        
        // convert total distance from meters to mi/km and round to tenths
        let roundedMiles = round((totalDistanceTravelled * metersToMiles) * 10)/10.0
        
        // update meters
        elapsedMeter.text = String(roundedMiles)
        timeMeter.text = String(totalTime)
        paceMeter.text = String(pace)
    }
    
    // update time variable and label
    private func updateTime() {
        // calculate time
        let endTime = NSDate().timeIntervalSince1970
        totalTime = Int((endTime - startTime) / 60)
        timeMeter.text = String(totalTime)
    }
    
    // function to present user with alert to allow them to exit the run
    // and return back to home screen.
    // run when the red "x" button is pressed
    @IBAction func cancelButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Cancel Run",
            message: "Are you sure you want to cancel your current run?",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: {
            (action) in
            // cancel location updates
            self.cancelLocationUpdates(locationManager: self.locationManager)
            
            // navigate to home page
            let storyBoard : UIStoryboard = UIStoryboard(name: "TabBar", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarStoryboard") as! UITabBarController
            self.show(nextViewController, sender:self)
        }))
        controller.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

extension RunViewController: CLLocationManagerDelegate {
    // to run whenever device provides app with updaated location information
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else { return }
        
        if startLocation == nil {
            startLocation = latestLocation.coordinate // store start location
            // map is loading -> place map at the start position of user
            zoomToCurrentLocation(coordinate: latestLocation.coordinate, animated: false)
        } else {
            // map is already present -> animate map to move to new location
            zoomToCurrentLocation(coordinate: latestLocation.coordinate, animated: true)
        }
        
        // update states (distance, time, pace) and cooresponding meter labels
        if currentLocation != nil {
            updateStats(latestLocation: latestLocation)
        }
        
        currentLocation = latestLocation // update current location
    }
    
    // to run whenever location permissions on device change
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
    // to run whenever device provides app with updated heading information
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading){
        rotateCamera(direction: newHeading.magneticHeading)
   }
}

