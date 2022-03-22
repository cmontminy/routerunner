//
//  SettingsTableViewCell.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Turn off all switches first
        uiSwitch.isOn = false
    }
    
    //Called when the switch is pressed
    @IBAction func changeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            print("on")
        } else {
            print("off")
        }
    }
}
