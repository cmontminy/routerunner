//
//  ViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/8/22.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        //validate text fields
        let error = validateFields()
        if(error != nil){
            //error has occured, display error text
            showError(error!)
            return
        }
        //strip whitespace and newlines from fields
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //sign in user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if(error != nil){
                //couldn't sign in
//                self.showError("Incorrect email and/or password")
                self.showError(error!.localizedDescription)
                return
            } else {
                //transition to home screen
                self.performSegue(withIdentifier: "LoginToHomeSegue", sender: self)
            }
        }
    }
    
    func validateFields() -> String? {
        //check that all fields are filled in
        if((emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "")){
            return "Please fill in all fields"
        }
        return nil
    }
    
    func showError(_ message:String){
        let errorController = UIAlertController(
            title: "Error",
            message: "\(message)",
            preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorController.addAction(OKAction)
        present(errorController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startObserving(&UserInterfaceStyleManager.shared)
    }
}
