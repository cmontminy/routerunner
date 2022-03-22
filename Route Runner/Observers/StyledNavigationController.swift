//
//  StyledNavigationController.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//

import UIKit

class StyledNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        startObserving(&UserInterfaceStyleManager.shared)
    }
}
