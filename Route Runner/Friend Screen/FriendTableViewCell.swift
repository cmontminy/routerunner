//
//  FriendTableViewCell.swift
//  Route Runner
//
//  Created by Truman Byrd on 5/3/22.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var skillLevel: UILabel!
    @IBOutlet weak var card: Card!
    
    var profileAction: ((UITableViewCell) -> Void)?
    var removeAction: ((UITableViewCell) -> Void)?
    
    
    @IBAction func onProfileButtonPressed(_ sender: Any) {
        profileAction?(self)
    }
    
    @IBAction func onRemoveButtonPressed(_ sender: Any) {
        removeAction?(self)
    }
    
}
