//
//  SettingsViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://linuxtut.com/en/1637e20fc62841ff68db/ - Referenced for creating and using SettingsTableViewCell

import UIKit

// List to keep track of all settings
public var settingsList = ["Dark Mode", "Distance Units"]

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let textCellIdentifier = "TextCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "TextCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! SettingsTableViewCell
        let row = indexPath.row
        cell.label?.text = settingsList[row].description
        //IndexPath on switch tag.Enter the value of row
        cell.uiSwitch.tag = indexPath.row
        //Behavior when the switch is pressed
        cell.uiSwitch.addTarget(self, action: #selector(changeSwitch(_:)), for: UIControl.Event.valueChanged)
        
        return cell
    }
    
    @objc func changeSwitch(_ sender: UISwitch) {
        /*
         sender.The tag contains the position of the switch cell(Int)
         sender.switch on for isOn/off Information is entered(Bool)
The print statement below shows the contents of the label in the cell and the true switch./False
         */
        switch sender.tag {
        case 0:

            let darkModeOn = sender.isOn
                    
            // 2
            // Store in UserDefaults
            UserDefaults.standard.set(darkModeOn, forKey: UserInterfaceStyleManager.userInterfaceStyleDarkModeOn)
            
            // 3
            // Update interface style
            UserInterfaceStyleManager.shared.updateUserInterfaceStyle(darkModeOn)
        default:
            return
        }
    
        
//        print(settingsList[sender.tag] + "But\(sender.isOn)Became")
    }
}
