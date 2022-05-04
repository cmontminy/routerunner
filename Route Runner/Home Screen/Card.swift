//
//  Card.swift
//  Route Runner
//
//  Created by Sriram Alagappan on 5/4/22.
//

import UIKit

@IBDesignable class Card: UIView {
    //Shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOpacity: Float = 1 {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 10.0 {
        didSet {
            self.updateView()
        }
    }

    //Apply params
    func updateView() {
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
        self.layer.cornerRadius = 5
    }
}
