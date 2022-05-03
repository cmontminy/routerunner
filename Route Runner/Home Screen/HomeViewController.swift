//
//  HomeViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/20/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "RouteCell";
    var routes:[RunData] = [];
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        cell.distanceLabel.text = String(routes[row].distance) + " mi"
        cell.timeLabel.text = String(routes[row].time) + " min"
        cell.routeImage.image = routes[row].image
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
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
                    
                    print(name, distance, time)
                    
                    // create route and append to list of all routes
                    let curRoute = RunData(name: name, image: UIImage(named: "sample3"), date: Date(), distance: distance, points: points, time: time)
                    self.routes.append(curRoute)
                }
                self.tableView.reloadData() // after loading routes, rebuild table
                self.removeSpinner() // remove spinner from screen
            }
        }
    }
    
    // Create a dummy run document on page load for firebase testing
//    func createDummyRunFirebase() {
//        let db = Firestore.firestore()
//        let docRef = db.collection("runs").document("sample")
//
//        docRef.getDocument(as: RunData.self) { result  in
//            switch result {
//            case .success(let run):
//                print("Run: \(run.name)")
//            case .failure(let error):
//                print("Error decoding run: \(error)")
//            }
//        }
//        try? db.collection("runs").addDocument(from: RunData(name: "testing", image: nil, date: Date(), distance: 123.4, points: 5, time: 8))
//    }
    
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
