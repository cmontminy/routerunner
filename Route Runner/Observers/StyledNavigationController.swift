//
//  StyledNavigationController.swift
//  Project: Route Runner
//  EID: crm4772
//  Course: CS371L
//
//  Created by Colette Montminy on 3/21/22.
//
//  From Lee Kah Seng - https://swiftsenpai.com/development/implement-in-app-dark-mode-using-swift-observation-protocols/

import UIKit

class StyledNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        startObserving(&UserInterfaceStyleManager.shared)
    }
}
