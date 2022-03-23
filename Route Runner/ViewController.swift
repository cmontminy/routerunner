//
//  ViewController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/8/22.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func loginButtonPressed(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startObserving(&UserInterfaceStyleManager.shared)
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "Yellow background")!)
    }


}

