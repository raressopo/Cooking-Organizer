//
//  UIButton+Config.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 06/02/2023.
//  Copyright © 2023 Rares Soponar. All rights reserved.
//

import Foundation

extension UIButton {
    
    func secondaryButtonSetup() {
        self.titleLabel?.font = UIFont(name: FontName.bold.rawValue, size: 17.0)
        self.setTitleColor(UIColor.secondaryButtonColor(), for: .normal)
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.secondaryButtonColor().cgColor
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    func primaryButtonSetup(withFontName fontName: FontName = .bold) {
        self.titleLabel?.font = UIFont(name: fontName.rawValue, size: 18.0)
        self.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
    }
    
    func lightPrimaryButtonSetup() {
        primaryButtonSetup(withFontName: .light)
    }
    
    func onScreenButtonSetup(withFontName fontName: FontName, andSize size: CGFloat = 15.0) {
        self.layer.cornerRadius = self.frame.height / 2
        self.backgroundColor = UIColor.onScreenButton()
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.buttonTitleColor().cgColor
        self.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        self.titleLabel?.font = UIFont(name: fontName.rawValue, size: size)
    }
    
}
