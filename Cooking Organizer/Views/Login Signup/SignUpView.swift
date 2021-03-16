//
//  SignUpView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class SignUpView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var signUpStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var confirmEMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var signUpValidationFailed: (() -> Void)?
    var signUpFailed: (() -> Void)?
    
    var invalidPassword: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SignUpView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        passwordTextField.isSecureTextEntry = true
        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard let email = eMailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty,
            let confirmEmail = confirmEMailTextField.text,
            let confirmPass = confirmPasswordTextField.text,
            !confirmEmail.isEmpty,
            !confirmPass.isEmpty,
            UtilsManager.isValidEmail(email) else
        {
            signUpValidationFailed?()

            return
        }
        
        let decimalCharacters = CharacterSet.decimalDigits
        
        guard let _ = password.rangeOfCharacter(from: decimalCharacters), password.count >= 6 else {
            invalidPassword?()
            
            return
        }
        
        UsersManager.shared.createUser(withEmail: email, password: password) { success in
            if success {
                self.removeFromSuperview()
            } else {
                self.signUpFailed?()
            }
        }
    }
}
