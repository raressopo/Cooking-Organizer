//
//  HomeScreenViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

enum MenuItems: CaseIterable {
    case homeIngredients
    case cookbook
    case cookingCalendar
    case shoppingList
    case settings
    
    var index: Int {
        switch self {
        case .homeIngredients:
            return 0
        case .cookbook:
            return 1
        case .cookingCalendar:
            return 2
        case .shoppingList:
            return 3
        case .settings:
            return 4
        }
    }
    
    var string: String {
        switch self {
        case .homeIngredients:
            return "Home Ingredients"
        case .cookbook:
            return "Cookbook"
        case .cookingCalendar:
            return "Cooking Calendar"
        case .shoppingList:
            return "Shopping List"
        case .settings:
            return "Settings"
        }
    }
}

class HomeScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HIWidgetTableViewCellDelegate {
    @IBOutlet weak var signUpDateLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dismissMenuButton: UIButton!
    
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var homeTableView: UITableView!
    
    var addSelectionView: AddSelectionView?
    
    var widgetHomeIngredient: HomeIngredient?
    var selectedRecipe: Recipe?
    var selectedDate: Date?
    var selectedShoppingList: ShoppingList?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UsersManager.shared.currentLoggedInUser {
            signUpDateLabel.text = user.data.signUpDate
        }
        
        menuTableView.delegate = self
        menuTableView.dataSource = self
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        UserDataManager.shared.homeIngredientDelegate = self
        
        homeTableView.register(UINib(nibName: "HIWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "hiWidgetCell")
        homeTableView.register(UINib(nibName: "CookbookWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "cookbookWidgetCell")
        homeTableView.register(UINib(nibName: "CookingCalendarWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "cookingCalendarCell")
        homeTableView.register(UINib(nibName: "ShoppingListWidgetTableViewCell", bundle: nil), forCellReuseIdentifier: "shoppingListWidgetCell")
        
        menuButton.layer.borderColor = UIColor.black.cgColor
        addButton.layer.borderColor = UIColor.black.cgColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        menuButton.isHidden = false
        dismissMenuButton.isHidden = true
        menuView.isHidden = true
        
        widgetHomeIngredient = nil
        selectedRecipe = nil
        selectedDate = nil
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        homeTableView.reloadData()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeIngredients", let hi = widgetHomeIngredient, let destinationVC = segue.destination as? HomeIngredientsViewController {
            destinationVC.widgetHomeIngredient = hi
        } else if segue.identifier == "recipeDetailsSegue", let recipe = selectedRecipe, let destinationVC = segue.destination as? RecipeDetailsViewController {
            destinationVC.recipe = recipe
        } else if segue.identifier == "cookingCalendarSegue", let date = selectedDate, let destinationVC = segue.destination as? CookingCalendarViewController {
            destinationVC.homeScreenDate = date
        } else if segue.identifier == "shoppingListWidgetSegue", let list = selectedShoppingList, let destinationVC = segue.destination as? ShoppingListViewController {
            destinationVC.selectedShoppingList = list
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func logOutPressed(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "loggedInUserId")
        
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        UserDefaults.standard.removeObject(forKey: "currentUserPassword")
        
        self.dismiss(animated: true)
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
        addSelectionView.shoppingListButton.addTarget(self, action: #selector(addShoppingList), for: .touchUpInside)
    }
    
    @IBAction func dismissMenuPressed(_ sender: Any) {
        menuButton.isHidden = false
        dismissMenuButton.isHidden = true
        menuView.isHidden = true
    }
    
    // MARK: - Table View Delegate and DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homeTableView {
            return 4
        } else {
            return MenuItems.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == homeTableView {
            var savedOrder = RearrangeHomeScreenView.getSavedHomeScreenOrder()
            
            if savedOrder.isEmpty {
                savedOrder = [.homeIngredients, .cookbook, .cookingCalendar, .shoppingList]
            }
            
            if indexPath.row == savedOrder.firstIndex(of: .homeIngredients) ?? 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "hiWidgetCell") as? HIWidgetTableViewCell else {
                    fatalError("cell should be HIWidgetTableViewCell type")
                }
                
                cell.selectionStyle = .none
                
                cell.delegate = self
                cell.HIWidgetTableView.reloadData()
                
                return cell
            } else if indexPath.row == savedOrder.firstIndex(of: .cookbook) ?? 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cookbookWidgetCell") as? CookbookWidgetTableViewCell else {
                    fatalError("cell should be CookbookWidgetTableViewCell type")
                }
                
                cell.selectionStyle = .none
                
                cell.delegate = self
                cell.recipesTableView.reloadData()
                
                return cell
            } else if indexPath.row == savedOrder.firstIndex(of: .cookingCalendar) ?? 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "cookingCalendarCell") as? CookingCalendarWidgetTableViewCell else {
                    fatalError("Cell type is not CookingCalendarWidgetTableViewCell")
                }
                
                cell.delegate = self
                cell.selectionStyle = .none
                cell.calendar.scope = .week
                
                cell.filterRecipesForDate(date: cell.calendar.selectedDate ?? Date())
                
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListWidgetCell") as? ShoppingListWidgetTableViewCell else {
                    fatalError("cell should be ShoppingListWidgetTableViewCell type")
                }
                
                cell.selectionStyle = .none
                
                cell.delegate = self
                cell.listOrItemsTableView.reloadData()
                
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
        
            cell?.textLabel?.text = MenuItems.allCases[indexPath.row].string
        
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == menuTableView {
            switch indexPath.row {
            case MenuItems.homeIngredients.index:
                performSegue(withIdentifier: "homeIngredients", sender: self)
                
                return
            case MenuItems.cookbook.index:
                performSegue(withIdentifier: "cookbookSegue", sender: self)
                
                return
            case MenuItems.cookingCalendar.index:
                performSegue(withIdentifier: "cookingCalendarSegue", sender: self)
                
                return
            case MenuItems.shoppingList.index:
                performSegue(withIdentifier: "shoppingListSegue", sender: self)
                
                return
            case MenuItems.settings.index:
                performSegue(withIdentifier: "settingsSegue", sender: self)
                
                return
            default:
                return
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == homeTableView {
            var savedOrder = RearrangeHomeScreenView.getSavedHomeScreenOrder()
            
            if savedOrder.isEmpty {
                savedOrder = [.homeIngredients,
                              .cookbook,
                              .cookingCalendar,
                              .shoppingList]
            }
            
            if indexPath.row == savedOrder.firstIndex(of: .cookingCalendar) ?? 2 {
                return 200
            } else {
                return 300
            }
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
    
    @objc func addShoppingList() {
        addSelectionView?.removeFromSuperview()
        
        let createListView = CreateShoppingListView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        createListView.translatesAutoresizingMaskIntoConstraints = false
        
        createListView.invalidName = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Invalid List Name",
                                                              message: "Please choose another list name!")
        }
        
        createListView.creationFailed = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Creation Failed",
                                                              message: "Something went wrong creating the shopping list")
        }
        
        view.addSubview(createListView)
        
        NSLayoutConstraint.activate([createListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                     createListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                     createListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                     createListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
    }
    
    // MARK: - User Data Manager Delegate
    
    func homeIngredientsAdded() {
        homeTableView.reloadData()
    }
    
    func homeIngredientsChanged() {
        homeTableView.reloadData()
    }
}

extension HomeScreenViewController: CookbookWidgetTableViewCellDelegate {
    func recipePressed(withRecipe recipe: Recipe) {
        selectedRecipe = recipe
        
        performSegue(withIdentifier: "recipeDetailsSegue", sender: self)
    }
}

extension HomeScreenViewController: UserDataManagerDelegate {
    func recipeChanged() {
        homeTableView.reloadData()
    }
    
    func shoppingListsChanged() {
        homeTableView.reloadData()
    }
}

extension HomeScreenViewController: CookingCalendarWidgetTableViewCellDelegate {
    func recipePressed(withDate date: Date) {
        selectedDate = date
        
        performSegue(withIdentifier: "cookingCalendarSegue", sender: self)
    }
}

extension HomeScreenViewController: ShoppingListWidgetTableViewCellDelegate {
    func didSelectShoppingList(list: ShoppingList) {
        selectedShoppingList = list
        
        performSegue(withIdentifier: "shoppingListWidgetSegue", sender: self)
    }
}
