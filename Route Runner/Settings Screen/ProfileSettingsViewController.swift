//
//  ProfileSettingsViewController.swift
//  Project: Route Runner
//  EID: crm4772
//  Course: CS371L
//
//  Created by Colette Montminy on 3/22/22.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class ProfileSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var models = [Section]() // array to store each section and its options for the table
    
    var data: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        configure() // call to set up models array
        tableView.delegate = self
        tableView.dataSource = self
        // register all types of table cells
        tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
        tableView.register(UINib(nibName: "EditableTableViewCell", bundle: nil), forCellReuseIdentifier: "EditableTableViewCell")
        
        startObserving(&UserInterfaceStyleManager.shared) // observer for darkmode style change
        
        print("starting up")
    }
    
    func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        guard let fetchedUser = try? document.data(as: UserData.self) else {
                            print("could not convert fetchedUser")
                            return
                        }
                        print("Name: \(fetchedUser.firstName)")
                        self.data = fetchedUser
                    }
                }
        }
    }
    
    func updateUserData(updateField:String, updateText:String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        document.reference.updateData([
                            updateField: updateText
                        ]) { err in
                            if let err = err {
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                    }
                }
        }
    }
    
    // function to set up option list - subtitles are dummy variables "test" for now
    func configure() {
        models.append(Section(title: "User Information", options: [
            .editableCell(model: SettingsEditOption(title: "First Name", subtitle: self.data?.firstName ?? "Could not load first name") {
                let controller = UIAlertController(
                    title: "Edit First Name",
                    message: "",
                    preferredStyle: .alert)
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new first name"
                })
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text!
                            
                            self.updateUserData(updateField: "firstName", updateText: enteredText)
                            
                            print(enteredText)
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
            
            .editableCell(model: SettingsEditOption(title: "Last Name", subtitle: self.data?.lastName ?? "Could not load last name") {
                let controller = UIAlertController(
                    title: "Edit Last Name",
                    message: "",
                    preferredStyle: .alert)
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new last name"
                })
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text!
                            
                            self.updateUserData(updateField: "lastName", updateText: enteredText)
                            
                            print(enteredText)
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
            // self.data?.address ?? "Could not load address"
            .editableCell(model: SettingsEditOption(title: "Address", subtitle: "test") {
                let controller = UIAlertController(
                    title: "Edit Address",
                    message: "",
                    preferredStyle: .alert)
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
                            let enteredText = textFields[0].text!
                            
                            self.updateUserData(updateField: "address", updateText: enteredText)
                            
                            print(enteredText)
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
            
            .editableCell(model: SettingsEditOption(title: "Experience", subtitle: self.data?.experienceLevel ?? "Could not load experience level") {
                let controller = UIAlertController(
                    title: "Choose a new experience level",
                    message: "",
                    preferredStyle: .actionSheet)
                
                controller.addAction(UIAlertAction(title: "Beginner", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Beginner")
                }))
                controller.addAction(UIAlertAction(title: "Intermediate", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Intermediate")
                }))
                controller.addAction(UIAlertAction(title: "Advanced", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Advanced")
                }))
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(controller, animated: true, completion: nil)
            })
        ]))
            
        models.append(Section(title: "Account Information", options: [
            .editableCell(model: SettingsEditOption(title: "Email", subtitle: self.data?.email ?? "Could not load email") {
                let controller = UIAlertController(
                    title: "Edit Email",
                    message: "",
                    preferredStyle: .alert)
                
                controller.addTextField(configurationHandler: {
                    (textField:UITextField!) in textField.placeholder = "Enter new email"
                })
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "OK",
                    style: .default,
                    handler: {
                        (paramAction:UIAlertAction!) in
                        if let textFieldArray = controller.textFields {
                            let textFields = textFieldArray as [UITextField]
                            let enteredText = textFields[0].text!
                            
                            Auth.auth().currentUser?.updateEmail(to: enteredText) { error in
                              print("could not reset email")
                            }
                            print("email updated !")
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
            
            .editableCell(model: SettingsEditOption(title: "Password", subtitle: "") {
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
                            let enteredText = textFields[0].text!
                            
                            Auth.auth().currentUser?.updatePassword(to: enteredText) { error in
                              print("password not accepted")
                            }
                            
                            print("password updated !")
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
    
    // set custom value for cell heights - all of them should be uniform
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0;
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
            cell.selectionStyle = .none
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
extension ProfileSettingsViewController: SwitchCellDelegate {
    func didTapSwitch(option: String, isOn: Bool) {
        return // no switches on this page at the moment, so does nothing
    }
}
