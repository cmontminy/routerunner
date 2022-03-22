//
//  SwitchTableViewCell.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://www.youtube.com/watch?v=2FigkAlz1Bg - Referenced for configure function

import UIKit

protocol SwitchCellDelegate: AnyObject {
    func didTapSwitch(with isOn: Bool)
}

class SwitchTableViewCell: UITableViewCell {
    
    static let identifier = "SwitchTableViewCell"

    weak var delegate: SwitchCellDelegate?
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func switchTapped(_ sender: Any) {
        delegate?.didTapSwitch(with: uiSwitch.isOn)
    }
    
    public func configure(with model: SettingsSwitchOption) {
        label.text = model.title
        uiSwitch.isOn = model.isOn
    }
}
