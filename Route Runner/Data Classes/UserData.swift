//
//  RunData.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit
import FirebaseAuth
import Firebase

// Data Class for storing/updating user info in firebase
class UserData: Codable {
    
    // Data fields
    var firstName: String
    var lastName: String
    var email: String
    var experienceLevel: String
    var uid: String
    var picture: UIImage
    
    init(firstName: String, lastName: String, email: String, experienceLevel: String, uid: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.experienceLevel = experienceLevel
        self.uid = uid
        self.picture = UIImage(named: "defaultProfile")!
    }
    
    static func downloadImage(_ gsurl: String, completionHandler: @escaping (_ result: UIImage?, _ error: Error?) -> Void) {
        let gsReference = Storage.storage().reference(forURL: gsurl)
        // 4 MB max image size
        gsReference.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let data = data {
                completionHandler(UIImage(data: data), error)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    // decoder constructor for comply with Codable
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try values.decode(String.self, forKey: .firstName)
        lastName = try values.decode(String.self, forKey: .lastName)
        email = try values.decode(String.self, forKey: .email)
        experienceLevel = try values.decode(String.self, forKey: .experienceLevel)
        uid = try values.decode(String.self, forKey: .uid)
        let profilePicURL = try values.decode(String.self, forKey: .profilePic)
        picture = UIImage(named: "defaultProfile")!
        UserData.downloadImage(profilePicURL) { image, err in
            if let err = err {
                print("Could not download image at URL \(profilePicURL), err: \(err.localizedDescription)")
            } else {
                guard let image = image else {
                    return
                }
                self.picture = image
            }
        }
    }
    
    // keys for use with decoding/encoding
    enum CodingKeys: String, CodingKey {
            case firstName
            case lastName
            case email
            case experienceLevel
            case uid
            case profilePic
    }
    
    // Instructions on how to create JSON document
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(experienceLevel, forKey: .experienceLevel)
        try container.encode(uid, forKey: .uid)
    }
    
    
}
