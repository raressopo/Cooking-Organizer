//
//  SettingsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum SettingsOptions: CaseIterable {
    case logout
    
    var cellTitle: String {
        switch self {
        case .logout:
            return "Log Out"
        }
    }
}

class SettingsViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var userProfileView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId")
        
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        UserDefaults.standard.removeObject(forKey: "currentUserPassword")
        
        self.dismiss(animated: true)
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsOptions.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "settingsCell")
        
        cell.textLabel?.text = SettingsOptions.allCases[indexPath.row].cellTitle
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SettingsOptions.allCases[indexPath.row] {
        case .logout:
            UserDefaults.standard.removeObject(forKey: "loggedInUserId")
            
            UserDefaults.standard.removeObject(forKey: "currentUserEmail")
            UserDefaults.standard.removeObject(forKey: "currentUserPassword")
            
            self.dismiss(animated: true)
        }
    }
}
