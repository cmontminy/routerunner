//
//  ViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/8/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startObserving(&UserInterfaceStyleManager.shared)
    }


}

