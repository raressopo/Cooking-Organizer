//
//  HomeScreenViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class HomeScreenViewController: UIViewController {
    @IBOutlet weak var signUpDateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UsersManager.shared.currentLoggedInUser, let signUpDate = user.signUpDate {
            signUpDateLabel.text = signUpDate
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            UserDefaults.standard.removeObject(forKey: "loggedInUser")
        }
    }
}
