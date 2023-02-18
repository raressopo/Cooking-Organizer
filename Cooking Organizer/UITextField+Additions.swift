//
//  UITextField+Additions.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 13/11/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func configure() {
        self.borderStyle = .none
        self.layer.cornerRadius = 14.0
        self.textAlignment = .center
        self.backgroundColor = UIColor.textFieldBackgroundColor()
        self.font = UIFont(name: FontName.regular.rawValue, size: 17.0)
    }
}
