//
//  RoundedButton.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 19/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    func greenColorForButton() {
        self.backgroundColor = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1)
        self.setTitleColor(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1), for: .normal)
    }
}
