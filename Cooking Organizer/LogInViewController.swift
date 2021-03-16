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
    
    @IBOutlet weak var spinnerView: UIView!
    
    var signUpView = SignUpView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    var isKeyboardDisplayed = false
    
    // MARK: - View Lifecylce
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideKeyboardWhenTappedAround()
        
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
        
        signUpView.signUpStackViewTopConstraint.constant = (view.frame.height - signUpView.stackViewHeightConstraint.constant) / 2
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        emailTextField.text = nil
        passTextField.text = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func signUpPressed(_ sender: Any) {
        signUpView = SignUpView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        signUpView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(signUpView)
        
        NSLayoutConstraint.activate([signUpView.topAnchor.constraint(equalTo: view.topAnchor), signUpView.leadingAnchor.constraint(equalTo: view.leadingAnchor), signUpView.trailingAnchor.constraint(equalTo: view.trailingAnchor), signUpView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        signUpView.signUpValidationFailed = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Sign Up Failed",
                                                              message: "Please check that E-Mail and password are correct and valid")
        }
        
        signUpView.signUpFailed = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Sign Up Failed",
                                                              message: "Something went wrong with the sign up. Please try again later!")
        }
        
        signUpView.invalidPassword = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Invalid Password",
                                                              message: "Your password should have at least 6 characters and at least 1 number!")
        }
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passTextField.text, !password.isEmpty else {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Log In Failed",
                                                                  message: "Make sure you entered the correct E-Mail and / or Password!")
                
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
                                                                  title: "Log In Failed",
                                                                  message: "Make sure you entered the correct E-Mail and / or Password!")
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupObservers(forUserId id: String) {
        UserDataManager.shared.observeHomeIngredientAdded(forUserId: id)
        UserDataManager.shared.observeHomeIngredientChanged(forUserId: id)
        UserDataManager.shared.observeHomeIngredientRemoved()
        
        UserDataManager.shared.observeRecipeAdded(forUserId: id)
        UserDataManager.shared.observeRecipeChanged(forUserId: id)
        UserDataManager.shared.observeRecipeRemoved()
        
        UserDataManager.shared.getCustomIngredients()
        
        UserDataManager.shared.observeShoppingListsChanged()
    }
    
    override func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if !isKeyboardDisplayed {
                signUpView.signUpStackViewTopConstraint.constant = (view.frame.height - keyboardHeight - signUpView.stackViewHeightConstraint.constant) / 2
                
                isKeyboardDisplayed = true
            }
        }
    }
    
    override func keyboardWillDisappear() {
        signUpView.signUpStackViewTopConstraint.constant = (view.frame.height - signUpView.stackViewHeightConstraint.constant) / 2
        
        isKeyboardDisplayed = false
    }
}

