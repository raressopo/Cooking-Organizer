//
//  SettingsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum SettingsOptions: CaseIterable {
    case homeScreenOrder
    
    var cellTitle: String {
        switch self {
        case .homeScreenOrder:
            return "Rearrange Home Screen"
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
        case .homeScreenOrder:
            let rearrangeHomeScreenView = RearrangeHomeScreenView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            rearrangeHomeScreenView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(rearrangeHomeScreenView)
            
            NSLayoutConstraint.activate([rearrangeHomeScreenView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0), rearrangeHomeScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0), rearrangeHomeScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), rearrangeHomeScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)])
        }
    }
}
