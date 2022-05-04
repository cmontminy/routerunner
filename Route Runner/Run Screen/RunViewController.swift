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
    @IBOutlet weak var popupView: UIView! // view for popup over map
    @IBOutlet weak var popupLabel: UILabel! // text for popup over map
    
    // -- Other Variables --
    private var totalDistanceTravelled: Double = 0 // used to store total distance user had travelled
    private var distanceForCurStep: Double = 0.0
    private var distanceToNextStep: Double = 0.0
    private var startTime = NSDate().timeIntervalSince1970 // start time stamp
    private var prevTime: Double = 0.0 // used to keep track of time since last updated for pace
    private var totalTime: Int = 0 // total time since this page loaded in minutes
    private var timer = Timer() // timer to be used to update time variables
    private var popupTimer = Timer() // timer used to control popup view
    public var routeData: RunData! = nil
    private var newPlaces: [(String,String)] = []
    private var distanceFormatter = MKDistanceFormatter()
    private var steps: [MKRoute.Step] = []
    private var stepIndex: Int = 0
    
    // -- Functions --
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // draw route on map
        if(routeData != nil && routeData.route != nil) {
            routeData.route!.calculate {response ,error in
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                let directionsRoute = response.routes[0]
                self.mapView.addOverlay((directionsRoute.polyline), level: MKOverlayLevel.aboveRoads)
                
                // set title to name and route distance length
                let unit = self.usingKilometers() ? "km" : "mi"
                self.routeLabel.text = self.routeData.name + "-" + String(self.routeData.distance) + unit
                
                self.steps = directionsRoute.steps
                print("----------------------------------")
                for step in directionsRoute.steps {
                    print(step.polyline.coordinate)
                }
                self.displayNextStepInRoute()
            }
        }
        configureLocationServices() // start location services
        scheduledTimerWithTimeInterval() // start timer
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    // to run anytime the view appears on the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // remove back button in nav bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // set labels to km or mi
        elapsedLabel.text = usingKilometers() ? "km" : "mi"
        paceLabel.text = usingKilometers() ? "km/hr" : "mi/hr"
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
        distanceForCurStep += distance
        
        // calculate time
        let endTime = NSDate().timeIntervalSince1970
        totalTime = Int((endTime - startTime) / 60)
        
        // detemrmine unit to convert to
        let conversion = usingKilometers() ? metersToKm : metersToMiles

        // calculate pace
        var pace:Double = 0.0
        if prevTime != 0.0 {
            let distConverted = distance * conversion
            pace = round((distConverted / ((endTime - prevTime) / 3600) ) * 10) / 10.0 // round to tenths
        }
        prevTime = endTime
        
        // convert total distance from meters to mi/km and round to tenths
        let roundedMiles = round((totalDistanceTravelled * conversion) * 10)/10.0
        
        // update meters
        elapsedMeter.text = String(roundedMiles)
        timeMeter.text = String(totalTime)
        paceMeter.text = String(pace)
        
        // check if we need to display next direction
        // add 10 meters to account for any miscalculations
        if (distanceForCurStep + 10 >= distanceToNextStep) {
            displayNextStepInRoute()
        }
        
        // identify nearby points of interest around a 75 meter radius
        let nearbyPointsReq = MKLocalPointsOfInterestRequest(center: latestLocation.coordinate, radius: 75.0)
        // filter requests
        nearbyPointsReq.pointOfInterestFilter = MKPointOfInterestFilter(including: [.amusementPark, .aquarium, .beach, .museum, .nationalPark, .stadium, .university, .zoo, .campground, .brewery, .library, .winery, .school, .theater, .movieTheater, .park])
        // search using request
        let search = MKLocalSearch(request: nearbyPointsReq)
        search.start { response, error in
            guard let response = response else {
                print(error as Any)
                return
            }
            for item in response.mapItems {
                let name = item.name!
                let locationType = item.pointOfInterestCategory?.rawValue
                let place = (name, locationType!)

                // if name is unique, add to new place array and display msg to user
                if (!self.contains(arr:self.newPlaces,t:place)) {
                    // append name to array
                    self.newPlaces.append(place)
                    
                    // display location
                    self.popupLabel.text = "New Place: " + name + "!"
                    self.setView(view: self.popupView, hidden: false)
                    
                    // close popup after 3 seconds
                    self.popupTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                        self.setView(view: self.popupView, hidden: true)
                    })
                }
            }
        }
    }
    
    // helper func to display next step in route
    private func displayNextStepInRoute() {
        // get next step
        self.stepIndex += 1
        if (self.stepIndex < steps.count) {
            let nextStep = self.steps[self.stepIndex]

            // display instructions
            let nextStepText = nextStep.notice ?? nextStep.instructions
            let nextStepDistance = self.distanceFormatter.string(
                fromDistance: nextStep.distance
              )
            self.directionLabel.text = nextStepText + "-" + nextStepDistance
            
            // set direction icon
            if nextStepText.contains("left") {
                self.directionIcon.image = UIImage(systemName: "arrow.left")
            } else if nextStepText.contains("right") {
                self.directionIcon.image = UIImage(systemName: "arrow.right")
            } else {
                self.directionIcon.image = UIImage(systemName: "arrow.up")
            }
            
            // update distance variables
            distanceForCurStep = 0.0
            distanceToNextStep = nextStep.distance
        }
    }
    
    // helper func to close/reveal views
    private func setView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    // helper func to compare tuples
    func contains(arr:[(String, String)], t:(String,String)) -> Bool {
        let (c1, c2) = t
        for (v1, v2) in arr { if v1 == c1 && v2 == c2 { return true } }
        return false
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

extension RunViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)

      renderer.strokeColor = .systemBlue // use default blue color for route
      renderer.lineWidth = 7.5
    
    return renderer
  }
}
