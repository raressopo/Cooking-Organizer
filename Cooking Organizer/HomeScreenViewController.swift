//
//  HomeScreenViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import FirebaseDatabase

enum MenuItems: CaseIterable {
    case HomeIngredients
    case Cookbook
    
    var index: Int {
        switch self {
        case .HomeIngredients:
            return 0
        case .Cookbook:
            return 1
        }
    }
    
    var string: String {
        switch self {
        case .HomeIngredients:
            return "Home Ingredients"
        case .Cookbook:
            return "Cookbook"
        }
    }
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HIWidgetTableViewCellDelegate, UserDataManagerDelegate {
    @IBOutlet weak var signUpDateLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dismissMenuButton: UIButton!
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var addSelectionView: AddSelectionView?
    
    var widgetHomeIngredient: HomeIngredient?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UsersManager.shared.currentLoggedInUser, let signUpDate = user.signUpDate {
            signUpDateLabel.text = signUpDate
        }
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        homeTableView.register(UINib(nibName: "HIWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "hiWidgetCell")
        
        menuButton.backgroundColor = UIColor.white
        menuButton.layer.cornerRadius = 25
        menuButton.layer.borderWidth = 1
        menuButton.layer.borderColor = UIColor.black.cgColor
        
        addButton.layer.cornerRadius = 25
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.black.cgColor
        
        if let loggedInUserId = UsersManager.shared.currentLoggedInUser?.id {
            UserDataManager.shared.observeRecipeAdded(forUserId: loggedInUserId, onSuccess: {
                
            }) {
                 AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self, title: "Recipes Fetch Failed", message: "Something went wrong while fetching recipes")
            }
            
            UserDataManager.shared.observeHomeIngredientChanged(forUserId: loggedInUserId) {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Ingredients Update Failed",
                                                                  message: "Something went wrong updating with new ingredient changes")
            }
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
    
    // MARK: - IBActions
    
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
    
    @IBAction func addPressed(_ sender: Any) {
        addSelectionView = AddSelectionView()
        
        guard let addSelectionView = addSelectionView else { return }
        
        view.addSubview(addSelectionView)
        
        addSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([addSelectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     addSelectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     addSelectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     addSelectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
        
        addSelectionView.homeIngredientButton.addTarget(self, action: #selector(addNewHomeIngredient(_:)), for: .touchUpInside)
        addSelectionView.recipeButton.addTarget(self, action: #selector(addNewRecipe), for: .touchUpInside)
    }
    
    @IBAction func dismissMenuPressed(_ sender: Any) {
        menuButton.isHidden = false
        dismissMenuButton.isHidden = true
        menuView.isHidden = true
    }
    
    // MARK: - Table View Delegate and DataSource
    
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
        
            cell?.textLabel?.text = MenuItems.allCases[indexPath.row].string
        
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            switch indexPath.row {
            case MenuItems.HomeIngredients.index:
                performSegue(withIdentifier: "homeIngredients", sender: self)
                
                return
            case MenuItems.Cookbook.index:
                performSegue(withIdentifier: "cookbookSegue", sender: self)
                
                return
            default:
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == homeTableView {
            return 300
        } else {
            return 44
        }
    }
    
    // MARK: - Home Ingredients Widget Delegate
    
    func homeIngredientPressed(withHomeIngredient hi: HomeIngredient) {
        widgetHomeIngredient = hi
        
        performSegue(withIdentifier: "homeIngredients", sender: self)
    }
    
    // MARK: - Selectors
    
    @objc func addNewHomeIngredient(_ sender: UIButton) {
        let ingredientDetailsView = HomeIngredientDetailsView()
        
        view.addSubview(ingredientDetailsView)
        
        ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
        
        guard let selectionView = addSelectionView else { return }
        
        selectionView.removeFromSuperview()
        addSelectionView = nil
    }
    
    @objc func addNewRecipe() {
        addSelectionView?.removeFromSuperview()
        
        performSegue(withIdentifier: "addNewRecipeSegue", sender: self)
    }
    
    // MARK: - User Data Manager Delegate
    
    func homeIngredientsAdded() {
        homeTableView.reloadData()
    }
    
    func homeIngredientsChanged() {
        homeTableView.reloadData()
    }
}
