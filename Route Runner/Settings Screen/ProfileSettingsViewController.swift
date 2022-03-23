//
//  ProfileSettingsViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/22/22.
//

import UIKit

class ProfileSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

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
        models.append(Section(title: "User Information", options: [
            .editableCell(model: SettingsEditOption(title: "Name", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Edit Name",
                    message: "",
                    preferredStyle: .alert)
                
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new name"
                })
                
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text
                            // do something with it to show it worked
                            print(enteredText!)
                        }
                    })
                )
                
                self.present(controller, animated: true, completion: nil)
            }),
            .editableCell(model: SettingsEditOption(title: "Address", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Edit Address",
                    message: "",
                    preferredStyle: .alert)

                // Dynamically create a text field.
                //    takes as a parameter a function that creates a text field object and
                //    adds the text field to an array called "textFields".
                //    "placeholder" is the initial text in the text field
                
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new address"
                })
                
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text
                            // do something with it to show it worked
                            print(enteredText!)
                        }
                    })
                )
                
                self.present(controller, animated: true, completion: nil)
            }),
            .editableCell(model: SettingsEditOption(title: "Experience", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Choose a new experience level",
                    message: "",
                    preferredStyle: .actionSheet)
                controller.addAction(UIAlertAction(title: "Beginner", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Intermediate", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Advanced", style: .default, handler: nil))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(controller, animated: true, completion: nil)
            })
        ]))
            
        models.append(Section(title: "Account Information", options: [
            .editableCell(model: SettingsEditOption(title: "Email", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Edit Username",
                    message: "",
                    preferredStyle: .alert)
                
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new username"
                })
                
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text
                            // do something with it to show it worked
                            print(enteredText!)
                        }
                    })
                )
                
                self.present(controller, animated: true, completion: nil)
            }),
            .editableCell(model: SettingsEditOption(title: "Password", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Edit Password",
                    message: "",
                    preferredStyle: .alert)
                
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new password"
                })
                
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text
                            // do something with it to show it worked
                            print(enteredText!)
                        }
                    })
                )
                
                self.present(controller, animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0;
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

extension ProfileSettingsViewController: SwitchCellDelegate {
    func didTapSwitch(option: String, isOn: Bool) {
        return
    }
}
