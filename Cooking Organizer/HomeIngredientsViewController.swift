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
    @IBOutlet weak var addHomeIngrButton: UIButton! {
        didSet {
            configureOnScreenButton(button: addHomeIngrButton, withFontSize: 15.0, fontName: "Proxima Nova Alt Regular")
        }
    }
    @IBOutlet weak var filterButton: UIButton! {
        didSet {
            configureOnScreenButton(button: filterButton, withFontSize: 15.0, fontName: "Proxima Nova Alt Regular")
        }
    }
    @IBOutlet weak var generateRecipesButton: UIButton! {
        didSet {
            configureOnScreenButton(button: generateRecipesButton, withFontSize: 17.0, fontName: "Proxima Nova Alt Bold")
        }
    }
    @IBOutlet weak var homeIngredientsTableView: UITableView!
    
    var homeIngredients = [HomeIngredient]()
    
    var deletedHomeIngredientsIds = [String]()
    
    var filteredHomeIngredients: [HomeIngredient]?
    var filterParams: HomeIngredientsFilterParams?
    
    var selectedSortOption: PantrySortOption?
    var isSortAscending = true
    
    var sortView: PantrySortView?
    var sortViewDismissBackgroundButton: UIButton?
    
    var generatedRecipesView: GeneratedRecipesView?
    var filterView: HomeIngredientsFilterView?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home Ingredients"
        
        self.view.backgroundColor = UIColor.screenBackground()
        
        homeIngredientsTableView.delegate = self
        homeIngredientsTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        homeIngredientsTableView.register(UINib(nibName: "HomeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "homeIngredientCell")
        
        displayHINavButtons()
        populateHomeIngredients()
        
        self.navigationController?.navigationBar.tintColor = UIColor.buttonTitleColor()
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
    
    @IBAction func generateRecipesPressed(_ sender: Any) {
        let spinnerView = SpinnerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(spinnerView)
        
        NSLayoutConstraint.activate([spinnerView.topAnchor.constraint(equalTo: view.topAnchor),
                                     spinnerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     spinnerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     spinnerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        if let items = navigationItem.rightBarButtonItems {
            for item in items {
                item.isEnabled = false
            }
        }
        
        guard let homeIngredients = UsersManager.shared.currentLoggedInUser?.homeIngredients, !homeIngredients.isEmpty, let recipes = UsersManager.shared.currentLoggedInUser?.recipes, !recipes.isEmpty else {
            spinnerView.removeFromSuperview()
            
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Generation Failed",
                                                              message: "EIther you don't have Home Ingredients or Recipes saved.")
            
            if let items = navigationItem.rightBarButtonItems {
                for item in items {
                    item.isEnabled = true
                }
            }
            
            return
        }
        
        var generatedRecipes = [GeneratedRecipe]()
        
        for recipe in recipes {
            var ingredientsCount = 0
            
            for homeIngredient in homeIngredients {
                if let recipeIngredients = recipe.ingredients {
                    for recipeIngredient in recipeIngredients {
                        if let recipeIngredientQuantity = recipeIngredient.quantityAsDouble,
                           let homeIngredientQuantity = homeIngredient.quantity,
                           recipeIngredient.name == homeIngredient.name,
                           recipeIngredientQuantity <= homeIngredientQuantity {
                            ingredientsCount += 1
                        }
                    }
                }
            }
            
            if (ingredientsCount == recipe.ingredients?.count || ingredientsCount == (recipe.ingredients?.count ?? 0) - 1) && ingredientsCount > 0 {
                generatedRecipes.append(GeneratedRecipe(id:recipe.id,
                                                        name: recipe.name,
                                                        totalIngredients: recipe.ingredients?.count ?? 0,
                                                        existingIngredients: ingredientsCount,
                                                        cookingDates: recipe.cookingDates))
            }
        }
        
        if generatedRecipes.isEmpty {
            spinnerView.removeFromSuperview()
            
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Generation Failed",
                                                              message: "You don't have enough home ingredients or the right home ingredients to generate saved recipes.")
            
            if let items = navigationItem.rightBarButtonItems {
                for item in items {
                    item.isEnabled = true
                }
            }
            
            return
        }
        
        spinnerView.removeFromSuperview()
        
        if generatedRecipesView == nil {
            generatedRecipesView = GeneratedRecipesView(withGeneratedRecipes: generatedRecipes, andFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
            if let generatedView = generatedRecipesView {
                generatedView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(generatedView)
                
                NSLayoutConstraint.activate([generatedView.topAnchor.constraint(equalTo: view.topAnchor),
                                             generatedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                             generatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                             generatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
                
                generatedView.delegate = self
                
                generatedView.dismissPressed = {
                    if let items = self.navigationItem.rightBarButtonItems {
                        for item in items {
                            item.isEnabled = true
                        }
                    }
                    
                    self.generatedRecipesView = nil
                }
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func configureOnScreenButton(button: UIButton, withFontSize size: CGFloat, fontName: String) {
        button.layer.cornerRadius = button.frame.height / 2
        button.backgroundColor = UIColor.onScreenButton()
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.buttonTitleColor().cgColor
        button.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        button.titleLabel?.font = UIFont(name: fontName, size: size)
    }
    
    private func populateHomeIngredients() {
        if let ingredients = UsersManager.shared.currentLoggedInUser?.homeIngredients {
            homeIngredients = ingredients
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
        generateRecipesButton.isHidden = inEdit
        
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
    
    private func displayHINavButtons() {
        self.navigationItem.title = "Home Ingredients"
        
        if let font = UIFont(name: "Proxima Nova Alt Bold", size: 22.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
        }
        
        let editNavBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editPressed))
        let sortNavBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortPressed))
        
        if let cancelFont = UIFont(name: "Proxima Nova Alt Regular", size: 18.0) {
            editNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                     NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                    for: .normal)
            editNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                     NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                    for: .highlighted)
            sortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                     NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                    for: .normal)
            sortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                     NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                    for: .highlighted)
        }
        
        navigationItem.rightBarButtonItems = [sortNavBarButton, editNavBarButton]
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = false
        navigationItem.backBarButtonItem?.tintColor = UIColor.buttonTitleColor()
    }
    
    @objc
    private func editPressed() {
        setupScreenMode(inEditMode: true)
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
    
    @objc private func cancelPressed() {
        setupScreenMode(inEditMode: false)
    }
    
    
}

// MARK: - TableView Delegate and DataSource

extension HomeIngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredHomeIngredients?.count ?? homeIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeIngredientCell", for: indexPath) as? HomeIngredientTableViewCell else {
            fatalError("cell should be HomeIngredientTableViewCell type")
        }
        
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
        return 86
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedHomeIngredientsIds.append(filteredHomeIngredients?[indexPath.row].id ?? homeIngredients[indexPath.row].id)
            
            if filteredHomeIngredients != nil {
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

// MARK: - Generate Recipes Delegate

extension HomeIngredientsViewController: GeneratedRecipesViewDelegate {
    func didSelectedRecipeToBeScheduled(recipe: GeneratedRecipe) {
        let scheduleRecipeView = ScheduleRecipeView(withRecipe: recipe, andFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        scheduleRecipeView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scheduleRecipeView)
        
        NSLayoutConstraint.activate([scheduleRecipeView.topAnchor.constraint(equalTo: view.topAnchor),
                                     scheduleRecipeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     scheduleRecipeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     scheduleRecipeView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        
        scheduleRecipeView.delegate = self
    }
}

// MARK: - Schedule Recipe after Generate Recipes Delegate

extension HomeIngredientsViewController: ScheduleRecipeViewDelegate {
    func didScheduleRecipes() {
        generatedRecipesView?.removeFromSuperview()
        
        if let items = self.navigationItem.rightBarButtonItems {
            for item in items {
                item.isEnabled = true
            }
            
            self.generatedRecipesView = nil
        }
    }
}

// MARK: - Sorting

extension HomeIngredientsViewController {
    
    // MARK: - Private helpers
    
    private func sortHomeIngredients(withSortOption option: PantrySortOption) {
        var ingredients = filteredHomeIngredients ?? homeIngredients
        
        ingredients.sort(by: { (ingredient1, ingredient2) -> Bool in
            switch (option, self.isSortAscending) {
            case (.name, true):
                if let ingredient1Name = ingredient1.name, let ingredient2Name = ingredient2.name {
                    return ingredient1Name.compare(ingredient2Name) == .orderedAscending
                } else {
                    return false
                }
            case (.name, false):
                if let ingredient1Name = ingredient1.name, let ingredient2Name = ingredient2.name {
                    return ingredient1Name.compare(ingredient2Name) == .orderedDescending
                } else {
                    return false
                }
            case (.expirationDate, true):
                if let ingredient1ExpirationDate = ingredient1.expirationDateAsDate, let ingredient2ExpirationDate = ingredient2.expirationDateAsDate {
                    return ingredient1ExpirationDate.compare(ingredient2ExpirationDate) == .orderedAscending
                } else {
                    return false
                }
            case (.expirationDate, false):
                if let ingredient1ExpirationDate = ingredient1.expirationDateAsDate, let ingredient2ExpirationDate = ingredient2.expirationDateAsDate {
                    return ingredient1ExpirationDate.compare(ingredient2ExpirationDate) == .orderedDescending
                } else {
                    return false
                }
            }
        })
        
        if filteredHomeIngredients != nil {
            filteredHomeIngredients = ingredients
        } else {
            homeIngredients = ingredients
        }
        
        homeIngredientsTableView.reloadData()
    }
    
    private func sortBackgroundButtonSetup() {
        sortViewDismissBackgroundButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        sortViewDismissBackgroundButton?.setTitle("", for: .normal)
        sortViewDismissBackgroundButton?.alpha = 0.4
        sortViewDismissBackgroundButton?.backgroundColor = .lightGray
        
        sortViewDismissBackgroundButton?.addTarget(self, action: #selector(dismissSortViewBackgroundPressed), for: .touchUpInside)
        
        view.addSubview(sortViewDismissBackgroundButton!)
        
        sortViewDismissBackgroundButton?.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([sortViewDismissBackgroundButton!.topAnchor.constraint(equalTo: view.topAnchor),
                                     sortViewDismissBackgroundButton!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     sortViewDismissBackgroundButton!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     sortViewDismissBackgroundButton!.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
    }
    
    private func removeSortBackgroundButton() {
        sortViewDismissBackgroundButton?.removeFromSuperview()
        
        sortViewDismissBackgroundButton = nil
    }
    
    private func dismissSortView(discardChanges: Bool) {
        if discardChanges == false, let sortView = self.sortView {
            self.selectedSortOption = sortView.selectedSortOption
            self.isSortAscending = sortView.ascendingDescendingSegmentedControl.selectedSegmentIndex == 0
        }
        
        self.sortView?.removeFromSuperview()
        
        self.sortView = nil
        
        removeSortBackgroundButton()
        
        let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        let sortNavBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortPressed))
        
        navigationItem.rightBarButtonItems = [sortNavBarButton, editNavBarButton]
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(false, animated: false)
        navigationItem.title = "Home Ingredients"
        
        if discardChanges == false, let option = self.selectedSortOption {
            self.sortHomeIngredients(withSortOption: option)
        }
    }
    
    // MARK: - Private Selectors
    
    @objc private func sortPressed() {
        sortBackgroundButtonSetup()
        
        sortView = PantrySortView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: 200,
                                                  height: 145))
        
        if let sortView = sortView {
            sortView.selectedSortOption = self.selectedSortOption
            sortView.ascendingDescendingSegmentedControl.selectedSegmentIndex = self.isSortAscending == true ? 0 : 1
            
            let sortDoneNavBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(sortDonePressed))
            let resetSortNavBarButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetSortPressed))
            let cancelSortNavBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSortPressed))
            
            navigationItem.rightBarButtonItems = [sortDoneNavBarButton, resetSortNavBarButton]
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.leftBarButtonItem = cancelSortNavBarButton
            navigationItem.title = "Sort Recipes"
            
            sortView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(sortView)
            
            NSLayoutConstraint.activate([sortView.heightAnchor.constraint(equalToConstant: 250),
                                         sortView.topAnchor.constraint(equalTo: homeIngredientsTableView.topAnchor, constant: 8),
                                         sortView.trailingAnchor.constraint(equalTo: homeIngredientsTableView.trailingAnchor, constant: -8),
                                         sortView.widthAnchor.constraint(equalToConstant: 200)])
        }
    }
    
    @objc private func sortDonePressed() {
        dismissSortView(discardChanges: false)
    }
    
    @objc private func resetSortPressed() {
        self.sortView?.selectedSortOption = nil
        self.sortView?.ascendingDescendingSegmentedControl.selectedSegmentIndex = 0
        
        dismissSortView(discardChanges: false)
    }
    
    @objc private func cancelSortPressed() {
        dismissSortView(discardChanges: true)
    }
    
    @objc private func dismissSortViewBackgroundPressed() {
        dismissSortView(discardChanges: true)
    }
    
}

// MARK: - Filtering

extension HomeIngredientsViewController: HomeIngredientsFilterViewDelegate {
    
    @IBAction func filterPressed(_ sender: Any) {
        self.filterView = HomeIngredientsFilterView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.filterView?.configure(withFilterParams: self.filterParams)
        guard let filterView = self.filterView else { return }
        filterView.delegate = self
        
        displayFilterNavButton()
        
        view.addSubview(filterView)

        filterView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([filterView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     filterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     filterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     filterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    
    
    // MARK: Private Helpers
    
    private func filterHomeIngredients(withParams params: HomeIngredientsFilterParams) {
        filteredHomeIngredients = nil
        
        if let ingredients = UsersManager.shared.currentLoggedInUser?.homeIngredients {
            if let category = params.categoryString {
                filteredHomeIngredients = ingredients.filter({ hi -> Bool in
                    if let hiCategory = hi.category {
                        return category == hiCategory
                    } else {
                        return false
                    }
                })
            }

            switch params.expirationDate {
            case .expired:
                let hiIngredients = filteredHomeIngredients ?? ingredients

                filteredHomeIngredients = hiIngredients.filter({ hi -> Bool in
                    if let expirationDateString = hi.expirationDate, let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString) {
                        return !UtilsManager.isSelectedDate(selectedDate: expirationDate, inFutureOrInPresentToGivenDate: Date())
                    } else {
                        return false
                    }
                })
            case .oneWeek:
                let calendar = Calendar.current
                let addOneWeekToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: Date())
                let hiIngredients = filteredHomeIngredients ?? ingredients
                
                filteredHomeIngredients = hiIngredients.filter({ ingredient -> Bool in
                    if let expirationDateString = ingredient.expirationDate,
                       let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString),
                       let oneWeekDate = addOneWeekToCurrentDate {
                        return expirationDate <= oneWeekDate
                    } else {
                        return false
                    }
                })
            case .twoWeeks:
                let calendar = Calendar.current
                let addTwoWeeksToCurrentDate = calendar.date(byAdding: .weekOfYear, value: 2, to: Date())
                let hiIngredients = filteredHomeIngredients ?? ingredients
                
                filteredHomeIngredients = hiIngredients.filter({ ingredient -> Bool in
                    if let expirationDateString = ingredient.expirationDate,
                       let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString),
                       let twoWeeksDate = addTwoWeeksToCurrentDate {
                        return expirationDate <= twoWeeksDate
                    } else {
                        return false
                    }
                })
            case .oneMonthPlus:
                let calendar = Calendar.current
                let addOneMonthToCurrentDate = calendar.date(byAdding: .month, value: 1, to: Date())
                let hiIngredients = filteredHomeIngredients ?? ingredients
                
                filteredHomeIngredients = hiIngredients.filter({ ingredient -> Bool in
                    if let expirationDateString = ingredient.expirationDate,
                       let expirationDate = UtilsManager.shared.dateFormatter.date(from: expirationDateString),
                       let oneMonthDate = addOneMonthToCurrentDate {
                        return expirationDate <= oneMonthDate
                    } else {
                        return false
                    }
                })
            default:
                break
            }
        }
        
        if let selectedSortOption = selectedSortOption {
            sortHomeIngredients(withSortOption: selectedSortOption)
        }
    }
    
    private func displayFilterNavButton() {
        self.navigationItem.title = "Filter Home Ingredients"
        
        if let font = UIFont(name: "Proxima Nova Alt Bold", size: 22.0) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: font]
        }
        
        let cancelNavButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelFilterPressed))
        
        if let cancelFont = UIFont(name: "Proxima Nova Alt Light", size: 18.0) {
            cancelNavButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                    NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                   for: .normal)
            cancelNavButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                    NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                   for: .highlighted)
        }
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = cancelNavButton
        
        let resetFilterNavButton = UIBarButtonItem(title: "Reset",
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(resetFilterPressed))
        let doneFilteringNavButton = UIBarButtonItem(title: "Done",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(doneFilteringPressed))
        
        if let resetFont = UIFont(name: "Proxima Nova Alt Regular", size: 18.0),
           let doneFont = UIFont(name: "Proxima Nova Alt Bold", size: 18.0) {
            resetFilterNavButton.setTitleTextAttributes([NSAttributedString.Key.font: resetFont,
                                                         NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                        for: .normal)
            doneFilteringNavButton.setTitleTextAttributes([NSAttributedString.Key.font: doneFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                          for: .normal)
            resetFilterNavButton.setTitleTextAttributes([NSAttributedString.Key.font: resetFont,
                                                         NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                        for: .highlighted)
            doneFilteringNavButton.setTitleTextAttributes([NSAttributedString.Key.font: doneFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                          for: .highlighted)
        }
        
        self.navigationItem.rightBarButtonItems = [doneFilteringNavButton, resetFilterNavButton]
    }
        
    // MARK: Private Selectors
    
    @objc private func cancelFilterPressed() {
        displayHINavButtons()
        
        self.filterView?.removeFromSuperview()
    }
    
    @objc private func resetFilterPressed() {
        displayHINavButtons()
        
        filterParams = nil
        filteredHomeIngredients = nil
        
        self.filterView?.removeFromSuperview()
        
        homeIngredientsTableView.reloadData()
    }
    
    @objc private func doneFilteringPressed() {
        displayHINavButtons()
        
        if let params = self.filterView?.filterParams {
            filterParams = params
        
            filterHomeIngredients(withParams: params)
            
            self.filterView?.removeFromSuperview()
        
            homeIngredientsTableView.reloadData()
        }
    }
    
    func filterCanceledPressed() {
        displayHINavButtons()
    }
    
}
