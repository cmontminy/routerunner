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
