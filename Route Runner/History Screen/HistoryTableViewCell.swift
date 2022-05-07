//
//  HistoryTableViewCell.swift
//  Route Runner
//
//  Created by Truman Byrd on 3/21/22.
//

import UIKit

// Simple custom cell class to provide outlets to cell's labels / image
class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var runImage: UIImageView!
    
    @IBOutlet weak var runName: UILabel!
    
    @IBOutlet weak var runLocations: UILabel!
    
    @IBOutlet weak var runDate: UILabel!
    
    @IBOutlet weak var card: Card!
}
