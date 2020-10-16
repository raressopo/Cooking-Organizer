//
//  HomeIngredientsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

class HomeIngredientsViewController: UIViewController {
    @IBOutlet weak var addHomeIngrButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var homeIngredientsTableView: UITableView!
    
    var homeIngredients = [HomeIngredient]()
    
    var widgetHomeIngredient: HomeIngredient?
    
    var deletedHomeIngredientsIds = [String]()
    
    var filteredHomeIngredients: [HomeIngredient]?
    var filterParams: HomeIngredientsFilterParams?
    
    var selectedSortOption: SortStackViewButtons?
    
    var sortView: SortView?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home Ingredients"
        
        homeIngredientsTableView.delegate = self
        homeIngredientsTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        homeIngredientsTableView.register(UINib(nibName: "HomeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "homeIngredientCell")
        
        let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        let sortNavBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortPressed))
        
        navigationItem.rightBarButtonItems = [sortNavBarButton, editNavBarButton]
        
        populateHomeIngredients()
        displayHomeScreenHomeIngredient()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        widgetHomeIngredient = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func addPressed(_ sender: Any) {
        let ingredientDetailsView = HomeIngredientDetailsView()
        
        view.addSubview(ingredientDetailsView)
        
        ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        let filterView = HomeIngredientsFilterView(withCriterias: [.Availability, .Category], filterParams: filterParams, andFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.addSubview(filterView)
        
        filterView.delegate = self
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([filterView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     filterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     filterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     filterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    // MARK: - Private Helpers
    
    private func displayHomeScreenHomeIngredient() {
        if let ingredient = widgetHomeIngredient {
            let ingredientDetailsView = HomeIngredientDetailsView()
            
            ingredientDetailsView.populateFields(withIngredient: ingredient)
            
            view.addSubview(ingredientDetailsView)
            
            ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                         ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                         ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                         ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
            
            ingredientDetailsView.createButton.setTitle("Change", for: .normal)
        }
    }
    
    private func populateHomeIngredients() {
        if let params = filterParams {
            filterHomeIngredients(withParams: params)
        } else {
            if let ingredients = UsersManager.shared.currentLoggedInUser?.homeIngredients {
                homeIngredients = ingredients
            }
        }
        
        if let sortOption = selectedSortOption {
            self.selectedSortOption = sortOption
            
            sortHomeIngredients(withSortOption: sortOption)
        }
        
        homeIngredientsTableView.reloadData()
    }
    
    private func setupScreenMode(inEditMode inEdit: Bool) {
        populateHomeIngredients()
        
        homeIngredientsTableView.setEditing(inEdit, animated: true)
        
        navigationItem.hidesBackButton = inEdit
        addHomeIngrButton.isHidden = inEdit
        filterButton.isHidden = inEdit
        
        if inEdit {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))]
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        } else {
            let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
            let sortNavBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortPressed))
            
            navigationItem.rightBarButtonItems = [sortNavBarButton, editNavBarButton]
            navigationItem.leftBarButtonItem = nil
        }
        
        deletedHomeIngredientsIds.removeAll()
    }
    
    private func filterHomeIngredients(withParams params: HomeIngredientsFilterParams) {
        filteredHomeIngredients = nil
        
        if let ingredients = UsersManager.shared.currentLoggedInUser?.homeIngredients {
            if let category = params.name {
                filteredHomeIngredients = ingredients.filter({ hi -> Bool in
                    if let categories = hi.categories {
                        return categories.contains(category)
                    } else {
                        return false
                    }
                })
            }
            
            if params.available {
                let hiIngredients = filteredHomeIngredients ?? ingredients
                
                filteredHomeIngredients = hiIngredients.filter({ hi -> Bool in
                    if let expirationDateString = hi.expirationDate, let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString) {
                        return UtilsManager.isSelectedDate(selectedDate: expirationDate, inFutureOrInPresentToGivenDate: Date())
                    } else {
                        return false
                    }
                })
            }
            
            if params.expired {
                let hiIngredients = filteredHomeIngredients ?? ingredients
                
                filteredHomeIngredients = hiIngredients.filter({ hi -> Bool in
                    if let expirationDateString = hi.expirationDate, let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString) {
                        return !UtilsManager.isSelectedDate(selectedDate: expirationDate, inFutureOrInPresentToGivenDate: Date())
                    } else {
                        return false
                    }
                })
            }
        }
        
        if let selectedSortOption = selectedSortOption {
            sortHomeIngredients(withSortOption: selectedSortOption)
        }
    }
    
    private func sortHomeIngredients(withSortOption option: SortStackViewButtons) {
        var ingredients = filteredHomeIngredients ?? homeIngredients
        
        ingredients.sort(by: { (ingredient1, ingredient2) -> Bool in
            switch option {
            case .NameAscending:
                if let ingredient1Name = ingredient1.name, let ingredient2Name = ingredient2.name {
                    return ingredient1Name.compare(ingredient2Name) == .orderedAscending
                } else {
                    return false
                }
            case .NameDescending:
                if let ingredient1Name = ingredient1.name, let ingredient2Name = ingredient2.name {
                    return ingredient1Name.compare(ingredient2Name) == .orderedDescending
                } else {
                    return false
                }
            case .ExpirationDateAscending:
                if let ingredient1ExpirationDate = ingredient1.expirationDateAsDate, let ingredient2ExpirationDate = ingredient2.expirationDateAsDate {
                    return ingredient1ExpirationDate.compare(ingredient2ExpirationDate) == .orderedAscending
                } else {
                    return false
                }
            case .ExpirationDateDescending:
                if let ingredient1ExpirationDate = ingredient1.expirationDateAsDate, let ingredient2ExpirationDate = ingredient2.expirationDateAsDate {
                    return ingredient1ExpirationDate.compare(ingredient2ExpirationDate) == .orderedDescending
                } else {
                    return false
                }
            default:
                return false
            }
        })
        
        if filteredHomeIngredients != nil {
            filteredHomeIngredients = ingredients
        } else {
            homeIngredients = ingredients
        }
        
        homeIngredientsTableView.reloadData()
    }
        
    // MARK: - Private Selectors
    
    @objc
    private func editPressed() {
        setupScreenMode(inEditMode: true)
    }
    
    @objc
    private func sortPressed() {
        if let sortView = sortView {
            sortView.removeFromSuperview()
            
            self.sortView = nil
            
            return
        } else {
            sortView = SortView(withButtons: [.NameAscending, .NameDescending, .ExpirationDateAscending, .ExpirationDateDescending], andFrame: CGRect(x: 0, y: 0, width: 250, height: 140))
            
            if let sortView = sortView {
                sortView.selectedSortOption = { sortOption in
                    self.selectedSortOption = sortOption
                    
                    self.sortHomeIngredients(withSortOption: sortOption)
                    
                    sortView.removeFromSuperview()
                }
                
                sortView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(sortView)
                
                NSLayoutConstraint.activate([sortView.heightAnchor.constraint(equalToConstant: 200),
                                             sortView.topAnchor.constraint(equalTo: homeIngredientsTableView.topAnchor, constant: 10),
                                             sortView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                             sortView.widthAnchor.constraint(equalToConstant: 250)])
            }
        }
    }
    
    @objc
    private func savePressed() {
        let dispatchGroup = DispatchGroup()
        
        for id in deletedHomeIngredientsIds {
            dispatchGroup.enter()
            
            UserDataManager.shared.removeHomeIngredient(withId: id) {
                if let loggedInUser = UsersManager.shared.currentLoggedInUser {
                    loggedInUser.data.homeIngredients?[id] = nil
                }
                
                dispatchGroup.leave()
            } failure: {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.setupScreenMode(inEditMode: false)
        }
    }
    
    @objc
    private func cancelPressed() {
        setupScreenMode(inEditMode: false)
    }
}

// MARK: - TableView Delegate and DataSource

extension HomeIngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHomeIngredients?.count ?? homeIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeIngredientCell", for: indexPath) as! HomeIngredientTableViewCell
        
        let homeIngredient = filteredHomeIngredients?[indexPath.row] ?? homeIngredients[indexPath.row]
        
        cell.name.text = homeIngredient.name
        cell.expirationDate.text = homeIngredient.expirationDate
        cell.quantityAndUnit.text = "\(homeIngredient.quantity ?? 0.0) \(homeIngredient.unit ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = filteredHomeIngredients?[indexPath.row] ?? homeIngredients[indexPath.row]
        
        let ingredientDetailsView = HomeIngredientDetailsView()
        
        ingredientDetailsView.populateFields(withIngredient: ingredient)
        
        view.addSubview(ingredientDetailsView)
        
        ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
        
        ingredientDetailsView.createButton.setTitle("Change", for: .normal)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedHomeIngredientsIds.append(filteredHomeIngredients?[indexPath.row].id ?? homeIngredients[indexPath.row].id)
            
            if let _ = filteredHomeIngredients {
                filteredHomeIngredients?.remove(at: indexPath.row)
            } else {
                homeIngredients.remove(at: indexPath.row)
            }
            
            homeIngredientsTableView.reloadData()
        }
    }
}

// MARK: - User Data Manager Delegate

extension HomeIngredientsViewController: UserDataManagerDelegate {
    func homeIngredientRemoved() {
        populateHomeIngredients()
    }
    
    func homeIngredientsChanged() {
        populateHomeIngredients()
    }
    
    func homeIngredientsAdded() {
        populateHomeIngredients()
    }
}

extension HomeIngredientsViewController: FilterViewDelegate {
    func homeIngredientFilterPressed(withParams params: HomeIngredientsFilterParams) {
        filterParams = params
        
        filterHomeIngredients(withParams: params)
        
        homeIngredientsTableView.reloadData()
    }
    
    func homeIngredientResetFilterPressed() {
        filterParams = nil
        filteredHomeIngredients = nil
        
        homeIngredientsTableView.reloadData()
    }
}
