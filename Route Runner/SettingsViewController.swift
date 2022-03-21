//
//  SettingsViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://linuxtut.com/en/1637e20fc62841ff68db/ - Referenced for creating and using SettingsTableViewCell
//  https://letcreateanapp.com/2021/04/15/how-to-create-uitableview-with-sections-in-swift-5/ - Referenced for creating TableView sections

import UIKit

// List to keep track of all settings
public var settingsList = ["Dark Mode", "Distance Units", "test3", "test4"]
public var sectionList = ["section 1", "section 2"]

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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
         
        let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width - 15, height: 40))
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.text = sectionList[section]
        view.addSubview(lbl)
        return view
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
        print(settingsList[sender.tag] + "But\(sender.isOn)Became")
    }
}
