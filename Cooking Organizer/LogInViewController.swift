//
//  LogInViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
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
    
    // MARK: - View Lifecylce
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let currentUserEmail = UserDefaults.standard.string(forKey: "currentUserEmail"),
            let currentUserPassword = UserDefaults.standard.string(forKey: "currentUserPassword") {
            spinnerView.isHidden = false
            
            UsersManager.shared.validateUserAndLogIn(withEmail: currentUserEmail, password: currentUserPassword) { userId in
                self.spinnerView.isHidden = true
                
                if let id = userId {
                    self.setupObservers(forUserId: id)
                    
                    self.performSegue(withIdentifier: "logInSegue", sender: self)
                } else {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Home Ingredients Fetch Failed",
                                                                      message: "Something went wrong while fetching Home Ingredients")
                }
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func cancelPressed(_ sender: Any) {
        signUpView.isHidden = true
        dismissSignUpViewButton.isHidden = true
    }
    
    @IBAction func createPressed(_ sender: Any) {
        spinnerView.isHidden = false
        dismissSignUpViewButton.isHidden = true
        signUpView.isHidden = true
        
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
        
        UsersManager.shared.createUser(withEmail: email, password: password) { success in
            if success {
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
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passTextField.text, !password.isEmpty else {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Invalid E-Mail and Password",
                                                                  message: "Please introduce valid E-mail and Password")
                
                return
        }
        
        spinnerView.isHidden = false
        
        UsersManager.shared.validateUserAndLogIn(withEmail: email, password: password) { userId in
            self.spinnerView.isHidden = true
            
            if let id = userId {
                self.setupObservers(forUserId: id)
                
                UserDefaults.standard.set(email, forKey: "currentUserEmail")
                UserDefaults.standard.set(password, forKey: "currentUserPassword")
                
                self.performSegue(withIdentifier: "logInSegue", sender: self)
            } else {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Home Ingredients Fetch Failed",
                                                                  message: "Something went wrong while fetching Home Ingredients")
            }
        }
    }
    
    @IBAction func dismissSignUpPressed(_ sender: Any) {
        signUpView.isHidden = true
        dismissSignUpViewButton.isHidden = true
    }
    
    // MARK: - Private Helpers
    
    private func setupObservers(forUserId id: String) {
        UserDataManager.shared.observeHomeIngredientAdded(forUserId: id)
        UserDataManager.shared.observeHomeIngredientChanged(forUserId: id)
        
        UserDataManager.shared.observeRecipeAdded(forUserId: id)
        UserDataManager.shared.observeRecipeChanged(forUserId: id)
    }
}

