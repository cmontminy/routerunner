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
        
        fetchUserData() { userData in
            self.data = userData
            print("finished gathering user data")
            self.configure()
            
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            // register all types of table cells
            self.tableView.register(UINib(nibName: "SettingsTableViewCell", bundle: nil), forCellReuseIdentifier: "SettingsTableViewCell")
            self.tableView.register(UINib(nibName: "SwitchTableViewCell", bundle: nil), forCellReuseIdentifier: "SwitchTableViewCell")
            self.tableView.register(UINib(nibName: "EditableTableViewCell", bundle: nil), forCellReuseIdentifier: "EditableTableViewCell")
            
            self.startObserving(&UserInterfaceStyleManager.shared) // observer for darkmode style change
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func fetchUserData(completionHandler: @escaping (UserData) -> Void) {
        print("here")
        var userData = UserData(firstName: "err", lastName: "err", email: "err", experienceLevel: "err", uid: "err")
        
        guard let user = Auth.auth().currentUser else {
            print("rip")
            return
        }
        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user.uid).getDocuments() { querySnapshot, err in
            if let err = err {
                print("Error in query \(err.localizedDescription)")
                completionHandler(userData)
                return
            }
            if querySnapshot!.isEmpty {
                print("No users with this uid")
                completionHandler(userData)
                return
            }
            userData = try! querySnapshot!.documents.first!.data(as: UserData.self)
            print("loaded user \(userData.firstName)")
            completionHandler(userData)
        }
    }
    
    func updateUserData(updateField:String, updateText:String, completionHandler: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else {
            return
        }

        let db = Firestore.firestore()
        db.collection("users").whereField("uid", isEqualTo: user.uid)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completionHandler()
                    return
                }
                for document in querySnapshot!.documents {
                    document.reference.updateData([
                        updateField: updateText
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully updated")
                        }
                        completionHandler()
                    }
                }
        }
    }
    
    // function to set up option list
    func configure() {
        models.removeAll()
        print("\(self.data?.firstName)")
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
                            
                            self.updateUserData(updateField: "firstName", updateText: enteredText) {
                                self.fetchUserData() { userData in
                                    self.data = userData
                                    self.configure()
                                    self.tableView.reloadData()
                                }
                            }
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
                            
                            self.updateUserData(updateField: "lastName", updateText: enteredText) {
                                self.fetchUserData() { userData in
                                    self.data = userData
                                    self.configure()
                                    self.tableView.reloadData()
                                }
                            }
                            
                            print(enteredText)
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
//            // self.data?.address ?? "Could not load address"
//            .editableCell(model: SettingsEditOption(title: "Address", subtitle: self.data?.address ?? "Could not load address") {
//                let controller = UIAlertController(
//                    title: "Edit Address",
//                    message: "",
//                    preferredStyle: .alert)
//                controller.addTextField(configurationHandler: {
//                    (textField:UITextField!) in textField.placeholder = "Enter new address"
//                })
//                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                controller.addAction(UIAlertAction(
//                    title: "OK",
//                    style: .default,
//                    handler: {
//                        (paramAction:UIAlertAction!) in
//                        if let textFieldArray = controller.textFields {
//                            let textFields = textFieldArray as [UITextField]
//                            let enteredText = textFields[0].text!
//
//                            self.updateUserData(updateField: "address", updateText: enteredText)
//
//                            print(enteredText)
//                        }
//                    })
//                )
//                self.present(controller, animated: true, completion: nil)
//            }),
            
            .editableCell(model: SettingsEditOption(title: "Experience", subtitle: self.data?.experienceLevel ?? "Could not load experience level") {
                let controller = UIAlertController(
                    title: "Choose a new experience level",
                    message: "",
                    preferredStyle: .actionSheet)
                
                controller.addAction(UIAlertAction(title: "Beginner", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Beginner") {
                        self.fetchUserData() { userData in
                            self.data = userData
                            self.configure()
                            self.tableView.reloadData()
                        }
                    }
                }))
                controller.addAction(UIAlertAction(title: "Intermediate", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Intermediate") {
                        self.fetchUserData() { userData in
                            self.data = userData
                            self.configure()
                            self.tableView.reloadData()
                        }
                    }
                }))
                controller.addAction(UIAlertAction(title: "Advanced", style: .default, handler: {_ in
                    self.updateUserData(updateField: "experienceLevel", updateText: "Advanced") {
                        self.fetchUserData() { userData in
                            self.data = userData
                            self.configure()
                            self.tableView.reloadData()
                        }
                    }
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
                            self.updateUserData(updateField: "email", updateText: enteredText) {
                                self.fetchUserData() { userData in
                                    self.data = userData
                                    self.configure()
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    })
                )
                self.present(controller, animated: true, completion: nil)
            }),
            
            .editableCell(model: SettingsEditOption(title: "Password", subtitle: "******") {
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
            }),
            
            .staticCell(model: SettingsOption(title: "Log out") {
                let controller = UIAlertController(
                    title: "Log Out",
                    message: "Are you sure you want to log out?",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                controller.addAction(UIAlertAction(
                    title: "Log out",
                    style: .default,
                    handler: { _ in
                        do {
                            try Auth.auth().signOut()
                            self.performSegue(withIdentifier: "LogOutSegue", sender: self)
                            print("successfully logged out")
                        } catch {
                            let errorController = UIAlertController(
                                title: "Error",
                                message: "Could not log out at this time. Please try again later.",
                                preferredStyle: .alert)
                            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                            errorController.addAction(OKAction)
                            self.present(errorController, animated: true, completion: nil)
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
    
    // set custom value for cell heights
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = models[indexPath.section].options[indexPath.row]
        
        switch model.self { // switch based on the type of cell
        case .staticCell( _):
            return 44.0
        case .switchCell( _):
            return 74.0
        case .editableCell( _):
            return 74.0
        }
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
        print(indexPath.row)
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
