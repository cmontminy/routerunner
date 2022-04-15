//
//  RouteTestingViewController.swift
//  Route Runner
//
//  Created by Truman Byrd on 4/14/22.
//
//  VC for testing route generation -- not accessible from app

import UIKit
import MapKit

class RouteTestingViewController: UIViewController {
    @IBOutlet weak var map: MKMapView!
    var directions: MKDirections!
    

    // show routes in diff colors
    var idx = 0
    var colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemPurple, .systemOrange]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        
        directions!.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.map.addOverlay(route.polyline)
                //set the map area to show the route
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                for step in route.steps {
                    print("Step: \(step.instructions)")
                }
            }
        }
    }
}

extension RouteTestingViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = colors[idx % colors.count]
        idx += 1
         renderer.lineWidth = 5.0
         return renderer
    }
}
