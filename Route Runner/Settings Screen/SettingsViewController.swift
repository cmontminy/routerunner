//
//  SettingsViewController.swift
//  Project: Route Runner
//  EID: crm4772
//  Course: CS371L
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://www.youtube.com/watch?v=2FigkAlz1Bg - Referenced for creating and using SettingsTableViewCell and model setup

import UIKit
import FirebaseAuth

struct Section { // keeps track of table view sections, includes header and included options
    let title: String
    let options: [SettingsOptionType]
}

struct SettingsSwitchOption { // settings option that includes a switch object
    let title: String
    var isOn: Bool
}

struct SettingsOption { // settings option that segues to another screen
    let title: String
    let handler: (() -> Void)
}

struct SettingsEditOption { // settings option that opens up a menu to edit values
    let title: String
    var subtitle: String
    let handler: (() -> Void)
}

enum SettingsOptionType { // keeps track of all three options
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
    case editableCell(model: SettingsEditOption)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var models = [Section]() // array to store each section and its options for the table
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure() // call to set up models array
        tableView.delegate = self
        tableView.dataSource = self
        // register all types of table cells
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
        tableView.register(UINib(nibName: "EditableTableViewCell", bundle: nil), forCellReuseIdentifier: "EditableTableViewCell")
        
        startObserving(&UserInterfaceStyleManager.shared) // observer for darkmode style change
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // function to set up option list
    func configure() {
        models.append(Section(title: "", options:[ // blank section name since there's only one option to display
            .staticCell(model: SettingsOption(title: "Profile Settings") {
                self.performSegue(withIdentifier: "ProfileSettingsIdentifier", sender: self)
            }),
        ]))
        models.append(Section(title: "General", options: [
            .switchCell(model: SettingsSwitchOption(title: "Dark Mode", isOn: UserInterfaceStyleManager.shared.currentStyle == .dark)),
            .switchCell(model: SettingsSwitchOption(title: "Distance Units", isOn: UserDefaults.standard.bool(forKey:"RouteRunnerKilometerModeOn"))),
            .switchCell(model: SettingsSwitchOption(title: "TTS Directions", isOn: UserDefaults.standard.bool(forKey:"RouteRunnerTTSModeOn")))
        ]))
            
//        models.append(Section(title: "Notifications", options: [
//            .staticCell(model: SettingsOption(title: "Mute while Running") {
//                print("tapped mute while running") // dummy action
//            }),
//            .staticCell(model: SettingsOption(title: "Vibration") {
//                print("tapped vibration") // dummy action
//            })
//        ]))
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self { // switch based on the type of cell
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else {
                return UITableViewCell() // default incase of failure
            }
            cell.configure(with: model) // populate cell information with model parameters
            return cell
            
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none // disable user selection of these rows
            cell.configure(with: model)
            cell.delegate = self // set up delegate to handle switch action
            return cell
        
        case .editableCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditableTableViewCell.identifier, for: indexPath) as? EditableTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self { // switch based on type of cell
        case .staticCell(let model):
            model.handler()
        case .switchCell(_):
            return // nothing to do since row can't be selected
        case .editableCell(let model):
            model.handler()
        }
    }
}

// handles satisfying the switch cell delegate function
extension SettingsViewController: SwitchCellDelegate {
    func didTapSwitch(option: String, isOn: Bool) {
        if option == "Dark Mode" { // action when dark mode switch is flipped
            let darkModeOn = isOn
            // Store in UserDefaults
            UserDefaults.standard.set(darkModeOn, forKey: UserInterfaceStyleManager.userInterfaceStyleDarkModeOn)
            // Update interface style
            UserInterfaceStyleManager.shared.updateUserInterfaceStyle(darkModeOn)
        } else if option == "Distance Units" { // action when distance mode switch is flipped
            let kmOn = isOn // isOn: true = kilometer mode on
            UserDefaults.standard.set(kmOn, forKey: "RouteRunnerKilometerModeOn")
        } else if option == "TTS Directions" { // action when TTS  mode switch is flipped
            let kmOn = isOn // isOn: true = TTS mode on
            UserDefaults.standard.set(kmOn, forKey: "RouteRunnerTTSModeOn")
        }
    }
}
