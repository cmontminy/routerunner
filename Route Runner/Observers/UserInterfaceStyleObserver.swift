//
//  UserInterfaceStyleObserver.swift
//  Route Runner
//
//  Created by Colette Montminy on 3/21/22.
//
//  From Lee Kah Seng - https://swiftsenpai.com/development/implement-in-app-dark-mode-using-swift-observation-protocols/

import Foundation
import UIKit

protocol UserInterfaceStyleObserver: AnyObject {
    func startObserving(_ userInterfaceStyleManager: inout UserInterfaceStyleManager)
    func userInterfaceStyleManager(_ manager: UserInterfaceStyleManager, didChangeStyle style: UIUserInterfaceStyle)
}


extension UIViewController: UserInterfaceStyleObserver {
    
    func startObserving(_ userInterfaceStyleManager: inout UserInterfaceStyleManager) {
        // Add view controller as observer of UserInterfaceStyleManager
        userInterfaceStyleManager.addObserver(self)
        
        // Change view controller to desire style when start observing
        overrideUserInterfaceStyle = userInterfaceStyleManager.currentStyle
    }
    
    func userInterfaceStyleManager(_ manager: UserInterfaceStyleManager, didChangeStyle style: UIUserInterfaceStyle) {
        // Set user interface style of UIViewController
        overrideUserInterfaceStyle = style
        
        // Update status bar style
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension UIView: UserInterfaceStyleObserver {
    
    func startObserving(_ userInterfaceStyleManager: inout UserInterfaceStyleManager) {
        // Add view as observer of UserInterfaceStyleManager
        userInterfaceStyleManager.addObserver(self)
        
        // Change view to desire style when start observing
        overrideUserInterfaceStyle = userInterfaceStyleManager.currentStyle
    }
    
    func userInterfaceStyleManager(_ manager: UserInterfaceStyleManager, didChangeStyle style: UIUserInterfaceStyle) {
        // Set user interface style of UIView
        overrideUserInterfaceStyle = style
    }
}
