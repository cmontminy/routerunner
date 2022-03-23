//
//  SettingsTableViewCell.swift
//  Project: Route Runner
//  EID: crm4772
//  Course: CS371L
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://www.youtube.com/watch?v=2FigkAlz1Bg - Referenced for configure function

import UIKit


class SettingsTableViewCell: UITableViewCell {
    
    static let identifier = "SettingsTableViewCell"
    
    @IBOutlet weak var label: UILabel!
    
    // configure function to populate cell variables with preset model parameters
    public func configure(with model: SettingsOption) {
        label.text = model.title
    }
}
