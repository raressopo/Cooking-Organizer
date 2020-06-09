//
//  HomeScreenViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum MenuItems: CaseIterable {
    case HomeIngredients
    
    var index: Int {
        switch self {
        case .HomeIngredients:
            return 0
        }
    }
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HIWidgetTableViewCellDelegate {
    @IBOutlet weak var signUpDateLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var dismissMenuButton: UIButton!
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var widgetHomeIngredient: HomeIngredient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UsersManager.shared.currentLoggedInUser, let signUpDate = user.signUpDate {
            signUpDateLabel.text = signUpDate
        }
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        homeTableView.register(UINib(nibName: "HIWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "hiWidgetCell")
        
        menuButton.backgroundColor = UIColor.white
        menuButton.layer.cornerRadius = 25
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.black.cgColor
        
        if let loggedInUserId = UsersManager.shared.currentLoggedInUser?.id {
            UserDataManager.shared.observeHomeIngredientChanged(forUserId: loggedInUserId)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        menuButton.isHidden = false
        dismissMenuButton.isHidden = true
        menuView.isHidden = true
        
        widgetHomeIngredient = nil
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        homeTableView.reloadData()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeIngredients", let hi = widgetHomeIngredient {
            let destinationVC = segue.destination as! HomeIngredientsViewController
            
            destinationVC.widgetHomeIngredient = hi
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            UserDefaults.standard.removeObject(forKey: "loggedInUser")
        }
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        menuButton.isHidden = true
        dismissMenuButton.isHidden = false
        menuView.isHidden = false
    }
    
    @IBAction func dismissMenuPressed(_ sender: Any) {
        menuButton.isHidden = false
        dismissMenuButton.isHidden = true
        menuView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homeTableView {
            return 1
        } else {
            return MenuItems.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == homeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hiWidgetCell") as! HIWidgetTableViewCell

            cell.selectionStyle = .none
            
            cell.delegate = self
            cell.HIWidgetTableView.reloadData()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
        
            cell?.textLabel?.text = "Home Ingredients"
        
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == MenuItems.HomeIngredients.index {
            performSegue(withIdentifier: "homeIngredients", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == homeTableView {
            return 300
        } else {
            return 44
        }
    }
    
    func homeIngredientPressed(withHomeIngredient hi: HomeIngredient) {
        widgetHomeIngredient = hi
        
        performSegue(withIdentifier: "homeIngredients", sender: self)
    }
}
