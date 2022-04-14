//
//  RegisterViewController.swift
//  Route Runner
//
//  Created by Paige Gibson on 4/8/22.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var selectSkillButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func selectSkillButtonPressed(_ sender: Any) {
        let controller = UIAlertController(
            title: "Select Skill Level",
            message: "Choose Level",
            preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action) in print("Cancel action")
        })
        controller.addAction(cancelAction)
        
        let beginnerAction = UIAlertAction(title: "Beginner", style: .default, handler: {
            (action) in print("Beginner selected")
            self.selectSkillButton.titleLabel?.text = "Beginner"
        })
        controller.addAction(beginnerAction)
        
        let intermediateAction = UIAlertAction(title: "Intermediate", style: .default, handler: {
            (action) in print("Intermediate selected")
            self.selectSkillButton.titleLabel?.text = "Intermediate"
        })
        controller.addAction(intermediateAction)
        
        let expertAction = UIAlertAction(title: "Expert", style: .default, handler: {
            (action) in print("Expert selected")
            self.selectSkillButton.titleLabel?.text = "Expert"
        })
        controller.addAction(expertAction)
        
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        //validate fields
        let error = validateFields()
        if(error != nil){
            //error has occured, display error text
            let errorController = UIAlertController(
                title: "Error",
                message: "\(error!)",
                preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            errorController.addAction(OKAction)
            present(errorController, animated: true, completion: nil)
            return
        }
        //create user
        //transition to home screen
    }
    
    //check fields and validates that all data is correct
    //if correct, return nil
    //if incorrect, return error message
    func validateFields() -> String? {
        //check that all fields are filled in
        if((firstNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (lastNameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ) || (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (passwordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (confirmPasswordField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "")){
            return "Please fill in all fields"
        }
        //check if skill level has been selected
        //if skill level has been selected, then the title of the button should
        //be chnaged to reflect the chosen skill level
        if(selectSkillButton.titleLabel?.text == "Select Skill Level"){
            return "Please select skill level"
        }
        //check if email is valid
        if(!isValidEmail(emailField.text!)){
            return "Please enter a valid email"
        }
        //check if password is valid
        if(!isValidPassword(passwordField.text!)){
            return "Please enter a valid password of at least 6 characters"
        }
        //check if confirm password field matches password field
        
        
        
        return nil
    }
    
    func isValidPassword(_ password: String) -> Bool {
      let minPasswordLength = 6
      return password.count >= minPasswordLength
    }
    func isValidEmail(_ email: String) -> Bool {
      let emailRegEx =
            "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
      let emailPred = NSPredicate(format:"SELF MATCHES %@",
            emailRegEx)
      return emailPred.evaluate(with: email)
    }
    

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
