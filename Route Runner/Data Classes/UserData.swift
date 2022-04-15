//
//  RunData.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit
import FirebaseAuth

// Data Class for storing/updating user info in firebase
class UserData: Codable {
    
    // Data fields
    var firstName: String
    var lastName: String
    var email: String
    var experienceLevel: String
    var uid: String
    
    init(firstName: String, lastName: String, email: String, experienceLevel: String, uid: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.experienceLevel = experienceLevel
        self.uid = uid
    }
}
