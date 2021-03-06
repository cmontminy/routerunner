//
//  RunData.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit
import FirebaseAuth
import MapKit

var routes: [RunData] = []

class RunData: Codable {
    
    // Data fields
    var name: String
    var locations: [String] // potentially want to create Location class
    var challenges: [String] // potentially want to create Challenge class
    var image: UIImage?
    var date: Date
    var distance: Double // stored in mi, convert to km when necessary
    var points: Int
    var time: Int // in seconds
    var pictureURL: String
    var route: MKDirections?
    var routeOverlay: MKRoute?
    var startCoordLat: Double?
    var endCoordLat: Double?
    var startCoordLong: Double?
    var endCoordLong: Double?
    var picture: UIImage?
    
    init(name: String, image: UIImage?, date: Date, distance: Double, points: Int, time: Int) {
        self.name = name
        self.locations = []
        self.challenges = []
        self.image = image
        self.date = date
        self.distance = distance
        self.points = points
        self.time = time
        self.pictureURL = ""
    }
    
    // decoder constructor for comply with Codable
    required init(from decoder: Decoder) throws {
        // Assign all values except image; need to figure out a solution/alternative for images
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        locations = try values.decode([String].self, forKey: .locations)
        challenges = try values.decode([String].self, forKey: .challenges)
        date = try values.decode(Date.self, forKey: .date)
        distance = try values.decode(Double.self, forKey: .distance)
        points = try values.decode(Int.self, forKey: .points)
        time = try values.decode(Int.self, forKey: .time)
        image = nil
        pictureURL = ""
    }
    
    // keys for use with decoding/encoding
    enum CodingKeys: String, CodingKey {
            case name
            case locations
            case challenges
            case image
            case date
            case distance
            case points
            case time
            case uid
            case startCoordLat
            case endCoordLat
            case startCoordLong
            case endCoordLong
            case pictureURL
    }
    
    // Instructions on how to create JSON document
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(locations, forKey: .locations)
        try container.encode(challenges, forKey: .challenges)
        try container.encode(date, forKey: .date)
        try container.encode(distance, forKey: .distance)
        try container.encode(points, forKey: .points)
        try container.encode(time, forKey: .time)
        guard let user = Auth.auth().currentUser else {
            return
        }
        try container.encode(user.uid, forKey: .uid)
        try container.encode(startCoordLat, forKey: .startCoordLat)
        try container.encode(endCoordLat, forKey: .endCoordLat)
        try container.encode(startCoordLong, forKey: .startCoordLong)
        try container.encode(endCoordLong, forKey: .endCoordLong)
        try container.encode(pictureURL, forKey: .pictureURL)
    }
    
    init(route directions: MKDirections) {
        route = directions
        name = "Untitled Run"
        locations = []
        challenges = []
        date = Date()
        points = 0
        distance = 0
        time = 0
        pictureURL = ""
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
    
    func getImage(completionHandler: @escaping (_ image: UIImage) -> Void) {
        if let picture = picture {
            completionHandler(picture)
        } else {
            if (pictureURL.count == 0) {
                completionHandler(self.randomDefaultImage())
            } else {
                UserData.downloadImage(pictureURL) { image, _ in
                    self.picture = image
                    completionHandler(self.picture!)
                }
            }
        }
    }
    
    func randomDefaultImage() -> UIImage {
        let index = Int.random(in: 0...5)
        return UIImage(named: "sample\(index)")!
    }
}
