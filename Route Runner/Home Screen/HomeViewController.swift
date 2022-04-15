//
//  HomeViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 3/20/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startObserving(&UserInterfaceStyleManager.shared)
        createDummyRunFirebase()
    }
    
    // Create a dummy run document on page load for firebase testing
    func createDummyRunFirebase() {
        let db = Firestore.firestore()
        let docRef = db.collection("runs").document("sample")

        docRef.getDocument(as: RunData.self) { result  in
            switch result {
            case .success(let run):
                print("Run: \(run.name)")
            case .failure(let error):
                print("Error decoding run: \(error)")
            }
        }
        try? db.collection("runs").addDocument(from: RunData(name: "testing", image: nil, date: Date(), distance: 123.4, points: 5, time: 8))
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
