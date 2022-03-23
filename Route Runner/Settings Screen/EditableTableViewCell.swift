//
//  EditableTableViewCell.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://www.youtube.com/watch?v=2FigkAlz1Bg - Referenced for configure function

import UIKit

class EditableTableViewCell: UITableViewCell {
    
    static let identifier = "EditableTableViewCell"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    
    public func configure(with model: SettingsEditOption) {
        label.text = model.title
        subLabel.text = model.subtitle
    }
}

