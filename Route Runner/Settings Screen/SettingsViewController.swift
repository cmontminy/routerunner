//
//  SettingsViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  https://www.youtube.com/watch?v=2FigkAlz1Bg - Referenced for creating and using SettingsTableViewCell and model setup

import UIKit

struct Section {
    let title: String
    let options: [SettingsOptionType]
}

struct SettingsSwitchOption {
    let title: String
    var isOn: Bool
}

struct SettingsOption {
    let title: String
    let handler: (() -> Void)
}

struct SettingsEditOption {
    let title: String
    let subtitle: String
    let handler: (() -> Void)
}

enum SettingsOptionType {
    case staticCell(model: SettingsOption)
    case switchCell(model: SettingsSwitchOption)
    case editableCell(model: SettingsEditOption)
}

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var models = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
        tableView.register(UINib(nibName: "EditableTableViewCell", bundle: nil), forCellReuseIdentifier: "EditableTableViewCell")
        
        startObserving(&UserInterfaceStyleManager.shared)
    }
    
    func configure() {
        models.append(Section(title: "", options:[
            .staticCell(model: SettingsOption(title: "Profile Settings") {
                self.performSegue(withIdentifier: "ProfileSettingsIdentifier", sender: self)
            }),
        ]))
        models.append(Section(title: "General", options: [
            .switchCell(model: SettingsSwitchOption(title: "Dark Mode", isOn: UserInterfaceStyleManager.shared.currentStyle == .dark)),
            .switchCell(model: SettingsSwitchOption(title: "Distance", isOn: UserDefaults.standard.bool(forKey:"RouteRunnerKilometerModeOn")))
        ]))
            
        models.append(Section(title: "Notifications", options: [
            .staticCell(model: SettingsOption(title: "Mute while Running") {
                print("tapped mute while running")
            }),
            .staticCell(model: SettingsOption(title: "Vibration") {
                print("tapped vibration")
            })
        ]))
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
        
        switch model.self {
        case .staticCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as? SettingsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: model)
            return cell
            
        case .switchCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchTableViewCell.identifier, for: indexPath) as? SwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(with: model)
            cell.delegate = self
            return cell
        
        case .editableCell(let model):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: EditableTableViewCell.identifier, for: indexPath) as? EditableTableViewCell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            cell.configure(with: model)
            return cell
        }
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let type = models[indexPath.section].options[indexPath.row]
        switch type.self {
        case .staticCell(let model):
            model.handler()
        case .switchCell(_):
            return
        case .editableCell(let model):
            model.handler()
        }
    }
}

extension SettingsViewController: SwitchCellDelegate {
    func didTapSwitch(option: String, isOn: Bool) {
        if option == "Dark Mode" {
            let darkModeOn = isOn
            // Store in UserDefaults
            UserDefaults.standard.set(darkModeOn, forKey: UserInterfaceStyleManager.userInterfaceStyleDarkModeOn)
            // Update interface style
            UserInterfaceStyleManager.shared.updateUserInterfaceStyle(darkModeOn)
        } else if option == "Distance" {
            let kmOn = isOn
            // Store in UserDefaults
            UserDefaults.standard.set(kmOn, forKey: "RouteRunnerKilometerModeOn")
        }
    }
}
