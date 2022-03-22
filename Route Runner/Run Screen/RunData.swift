//
//  RunData.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit

class RunData {
    
    var name: String
    var locations: Int
    var image: UIImage?
    var date: Date
    var distance: Double
    var points: Int
    var time: Int // in seconds
    var pace: Int // in seconds per mile
    
    init(name: String, locations: Int, image: UIImage?, date: Date, distance: Double, points: Int, time: Int, pace: Int) {
        self.name = name
        self.locations = locations
        self.image = image
        self.date = date
        self.distance = distance
        self.points = points
        self.time = time
        self.pace = pace
    }
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YYYY"
        return formatter.string(from: self.date)
    }
    
}
