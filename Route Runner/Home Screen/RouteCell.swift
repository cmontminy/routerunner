//
//  RouteCell.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 5/2/22.
//

import Foundation

import UIKit

class RouteCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var routeImage: UIImageView!
    @IBOutlet weak var card: Card!
}
