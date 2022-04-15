//
//  RouteAnnotation.swift
//  Route Runner
//
//  Created by Colette Montminy on 4/12/22.
//

import MapKit

class RouteAnnotation: NSObject {
  private let item: MKMapItem

  init(item: MKMapItem) {
    self.item = item

    super.init()
  }
}

// MARK: - MKAnnotation

extension RouteAnnotation: MKAnnotation {
  var coordinate: CLLocationCoordinate2D {
    return item.placemark.coordinate
  }

  var title: String? {
    return item.name
  }
}
