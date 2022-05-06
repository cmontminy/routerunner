//
//  HomeViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/20/22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestoreSwift

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteCell";
    var routes:[RunData] = [];
    let locationManager = CLLocationManager()
    private var curLocation: CLLocationCoordinate2D?
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // get user's current location
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        startObserving(&UserInterfaceStyleManager.shared)
        tableView.delegate = self
        tableView.dataSource = self
        getAllRunsFirebase()
        self.tableView.reloadData() // after loading routes, rebuild table
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RouteCell
        let row = indexPath.row
        cell.titleLabel.text = (routes[row].name)
        cell.distanceLabel.text = String(routes[row].distance) + (self.usingKilometers() ? " km" : " mi")
        cell.timeLabel.text = String(routes[row].time) + " min"
        cell.routeImage.image = routes[row].image
        cell.routeImage.layer.cornerRadius = 5
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routes.count
    }
    
    // Get all runs from firebase
    func getAllRunsFirebase() {
        let db = Firestore.firestore()
        self.showSpinner(onView: self.view) // show spinner
        db.collection("runs").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.removeSpinner() // remove spinner from screen
            } else {
                for document in querySnapshot!.documents {
                    // parse data and get properties
                    let data = document.data()
                    let name: String = data["name"] as? String ?? "(No Name)"
                    let distance: Double = data["distance"] as? Double ?? 0.0
                    let time: Int = data["time"] as? Int ?? 0
                    let points: Int = data["points"] as? Int ?? 0
                    let startCoordLat: Double = data["startCoordLat"] as? Double ?? 0.0
                    let startCoordLong: Double = data["startCoordLong"] as? Double ?? 0.0
                    let endCoordLat: Double = data["endCoordLat"] as? Double ?? 0.0
                    let endCoordLong: Double = data["endCoordLong"] as? Double ?? 0.0
                                        
                    // create route and append to list of all routes
                    let curRoute = RunData(name: name, image: UIImage(named: "sample3"), date: Date(), distance: distance, points: points, time: time)
                    curRoute.startCoordLat = startCoordLat
                    curRoute.startCoordLong = startCoordLong
                    curRoute.endCoordLat = endCoordLat
                    curRoute.endCoordLong = endCoordLong
                    
                    if self.curLocation != nil {
                        let distanceToStart = CLLocation(latitude: self.curLocation!.latitude, longitude: self.curLocation!.longitude).distance(from: CLLocation(latitude: startCoordLat, longitude: startCoordLong))
                        print(distanceToStart)
                        // anything 5km from here
                        if (distanceToStart < 5000) {
                            // only append nearyby routes
                            self.routes.append(curRoute)
                        }
                    }
                }
                self.tableView.reloadData() // after loading routes, rebuild table
                self.removeSpinner() // remove spinner from screen
            }
        }
    }
    
    // to run anytime the view appears on the screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // remove back button in nav bar
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // reset nav VC stack (removes run screen from stack after user navigates out)
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        let temp = navigationArray.last
        navigationArray.removeAll()
        navigationArray.append(temp!) //To remove all previous UIViewController except the last one
        self.navigationController?.viewControllers = navigationArray
    }
    
    // to run anytime the view leaves the screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // return back button in nav bar
        navigationController?.setNavigationBarHidden(false, animated: animated)
//        print("this should go first")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RouteInstanceIdentifier" {
            let nextVC = segue.destination as! RouteInstanceViewController
            
            let nextRoute = routes[tableView.indexPathForSelectedRow!.row]
            
            // generate route from coords
            let startLat = nextRoute.startCoordLat ?? 0.0
            let startLong = nextRoute.startCoordLong ?? 0.0
            let endLat = nextRoute.endCoordLat ?? 0.0
            let endLong = nextRoute.endCoordLong ?? 0.0
            
            // Create MKDirections Request
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: startLat, longitude: startLong)))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: endLat, longitude: endLong)))
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            let directions: MKDirections? = MKDirections(request: request)
            
            guard directions != nil else {
                return
            }
            
            nextRoute.route = directions
            
            nextVC.routeData = nextRoute // send generated run data to new page to display to user
            nextVC.generateData = false
        }
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        self.curLocation = locValue
    }
}
