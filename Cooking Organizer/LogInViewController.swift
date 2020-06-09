//
//  LogInViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UsersManagerDelegate {
    // MARK: - Log In
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
    // MARK: - Sign Up
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpConfirmEmailTextField: UITextField!
    @IBOutlet weak var signUpPassTextField: UITextField!
    @IBOutlet weak var signUpConfirmPassTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var dismissSignUpViewButton: UIButton!
    
    @IBOutlet weak var spinnerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView.isHidden = false
        
        UsersManager.shared.delegate = self
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        signUpView.isHidden = true
        dismissSignUpViewButton.isHidden = true
    }
    
    @IBAction func createPressed(_ sender: Any) {
        spinnerView.isHidden = false
        
        self.dismissSignUpViewButton.isHidden = true
        self.signUpView.isHidden = true
        
        guard let email = signUpEmailTextField.text,
            let password = signUpPassTextField.text,
            email.count > 0,
            password.count > 0 else
        {
            spinnerView.isHidden = true
            
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Sign Up Failed",
                                                              message: "Please check that E-Mail and password are correct and valid")
            return
        }
        
        UsersManager.shared.addUserToDB(with: email, password: password) { (error, ref) in
            if error == nil {
                self.spinnerView.isHidden = true
                
                self.signUpEmailTextField.text = ""
                self.signUpConfirmEmailTextField.text = ""
                self.signUpPassTextField.text = ""
                self.signUpConfirmPassTextField.text = ""
            } else {
                self.spinnerView.isHidden = true
                
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Sign Up Failed",
                                                                  message: "Something went wrong with the sign up. Please try again later!")
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        signUpView.isHidden = false
        dismissSignUpViewButton.isHidden = false
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        guard let email = emailTextField.text, email.count > 0,
            let password = passTextField.text, password.count > 0 else {
            // ALERT
            
            return
        }
        
        for user in UsersManager.shared.allUsers {
            if let userEmail = user.email, userEmail == email,
                let userPass = user.password, userPass == password,
                let userId = user.id {
                spinnerView.isHidden = false
                
                UserDataManager.shared.fetchUserDataForUserID(id: userId) { (success) in
                    if success {
                        UserDefaults.standard.set(userId, forKey: "loggedInUser")
                        UsersManager.shared.currentLoggedInUser = user
                        
                        UserDataManager.shared.observeHomeIngredientsAdded(forUserId: user.id!) {
                            self.spinnerView.isHidden = true
                            
                            self.performSegue(withIdentifier: "logInSegue", sender: self)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func dismissSignUpPressed(_ sender: Any) {
        signUpView.isHidden = true
        dismissSignUpViewButton.isHidden = true
    }
    
    func usersDidFetched() {
        spinnerView.isHidden = true
        
        if let loggedInUserId = UserDefaults.standard.value(forKey: "loggedInUser") as? String {
            spinnerView.isHidden = false
            
            UserDataManager.shared.fetchUserDataForUserID(id: loggedInUserId) { (success) in
                if success {
                    guard let currentUser = UsersManager.shared.allUsers.first(where: { (user) -> Bool in
                        if let userId = user.id {
                            return userId == loggedInUserId
                        } else {
                            return false
                        }
                    }) else {
                        // ALERT
                        return
                    }
                    
                    UsersManager.shared.currentLoggedInUser = currentUser
                    
                   UserDataManager.shared.observeHomeIngredientsAdded(forUserId: currentUser.id!) {
                        self.spinnerView.isHidden = true
                        
                        self.performSegue(withIdentifier: "logInSegue", sender: self)
                    }
                }
            }
        }
    }
}

