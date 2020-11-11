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
    
    @IBOutlet weak var eMailTextField: UITextField!
    @IBOutlet weak var confirmEMailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var signUpValidationFailed: (() -> Void)?
    var signUpFailed: (() -> Void)?
    
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
            email.count > 0,
            UtilsManager.isValidEmail(email),
            password.count > 0 else
        {
            signUpValidationFailed?()

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
