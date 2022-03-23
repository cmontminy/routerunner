//
//  RunData.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit

class RunData {
    
    // Data fields
    var name: String
    var locations: [String] // potentially want to create Location class
    var challenges: [String] // potentially want to create Challenge class
    var image: UIImage?
    var date: Date
    var distance: Double // stored in mi, convert to km when necessary
    var points: Int
    var time: Int // in seconds
    
    init(name: String, image: UIImage?, date: Date, distance: Double, points: Int, time: Int) {
        self.name = name
        self.locations = []
        self.challenges = []
        self.image = image
        self.date = date
        self.distance = distance
        self.points = points
        self.time = time
    }
    
    // Return the run's date in the format 01/31/1999
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter.string(from: self.date)
    }
    
    // Return the pace, in seconds, accounting for mi/km
    func getPace() -> Int {
        let km = UserDefaults.standard.bool(forKey:"RouteRunnerKilometerModeOn")
        let milesToKilo = 1.609344
        if (km) {
            return Int(Double(self.time) / (self.distance * milesToKilo))
        } else {
            return Int(Double(self.time) / self.distance)
        }
    }
    
    // Return the distance, accounting for mi/km
    func getDistance() -> Double {
        let km = UserDefaults.standard.bool(forKey:"RouteRunnerKilometerModeOn")
        let milesToKilo = 1.609344
        if (km) {
            return Double(self.distance * milesToKilo)
        } else {
            return self.distance
        }
    }
}
