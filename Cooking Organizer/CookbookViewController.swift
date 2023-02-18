//
//  CookbookViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class CookbookViewController: UIViewController {
    
    @IBOutlet weak var recipesTableView: UITableView! {
        didSet {
            self.recipesTableView.backgroundColor = UIColor.screenBackground()
        }
    }
    
    @IBOutlet weak var addRecipeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton! {
        didSet {
            filterButton.onScreenButtonSetup(withFontName: .regular)
        }
    }
    
    private var recipes = [Recipe]()
    private var filteredRecipes: [Recipe]?
    
    private var selectedRecipe: Recipe?
    
    private var deletedRecipesIds = [String]()
    
    var filterParams: RecipeFilterParams?
    
    var selectedSortOption: SortOption?
    var isSortAscending = true
    
    var sortView: CookbookSortView?
    var sortViewDismissBackgroundButton: UIButton?
    
    var filterView: RecipesFilterView?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        recipesTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        
        self.displayCookbookNavButtons()
        self.view.backgroundColor = UIColor.screenBackground()
        self.navigationController?.navigationBar.tintColor = UIColor.buttonTitleColor()
        self.tabBarController?.tabBar.tintColor = UIColor.buttonTitleColor()
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: FontName.bold.rawValue, size: 10.0)!], for: .normal)
        
        addRecipeButton.onScreenButtonSetup(withFontName: .bold)
        filterButton.onScreenButtonSetup(withFontName: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateRecipes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue", let destinationVC = segue.destination as? RecipeDetailsViewController {
            destinationVC.recipe = selectedRecipe
            
            selectedRecipe = nil
        }
    }
    
    // MARK: Private Helpers
    
    private func hideButtonsAndTabBar(hide: Bool) {
        self.tabBarController?.tabBar.isHidden = hide
        
        addRecipeButton.isHidden = hide
        filterButton.isHidden = hide
    }
    
    private func displayCookbookNavButtons() {
        hideButtonsAndTabBar(hide: false)
        
        self.navigationItem.title = "Cookbook"
        
        if let font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0) {
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
    
    private func displayFilterNavButton() {
        self.navigationItem.title = "Filter Recipes"
        
        if let font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0) {
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
    
    private func displaySortNavButtons() {
        let sortDoneNavBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(sortDonePressed))
        let resetSortNavBarButton = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetSortPressed))
        let cancelSortNavBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSortPressed))
        
        if let resetFont = UIFont(name: "Proxima Nova Alt Regular", size: 18.0),
           let doneFont = UIFont(name: "Proxima Nova Alt Bold", size: 18.0),
           let cancelFont = UIFont(name: "Proxima Nova Alt Light", size: 18.0) {
            resetSortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: resetFont,
                                                         NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                        for: .normal)
            sortDoneNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: doneFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                          for: .normal)
            resetSortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: resetFont,
                                                         NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                        for: .highlighted)
            sortDoneNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: doneFont,
                                                           NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                          for: .highlighted)
            cancelSortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                    NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                   for: .normal)
            cancelSortNavBarButton.setTitleTextAttributes([NSAttributedString.Key.font: cancelFont,
                                                    NSAttributedString.Key.foregroundColor: UIColor.buttonTitleColor()],
                                                   for: .highlighted)
        }
        
        navigationItem.rightBarButtonItems = [sortDoneNavBarButton, resetSortNavBarButton]
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.leftBarButtonItem = cancelSortNavBarButton
        navigationItem.title = "Sort Recipes"
    }
    
    private func populateRecipes() {
        if let params = filterParams {
            filterRecipes(withParams: params)
        } else {
            if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
                recipes = userRecipes
            }
        }
        
        if let sortOption = selectedSortOption {
            sortRecipes(withSortOption: sortOption, isAscending: self.isSortAscending)
        }
        
        recipesTableView.reloadData()
    }
    
    private func setupScreenMode(inEditMode inEdit: Bool) {
        self.tabBarController?.tabBar.isHidden = inEdit
        
        populateRecipes()
        
        recipesTableView.setEditing(inEdit, animated: true)
        
        navigationItem.hidesBackButton = inEdit
        addRecipeButton.isHidden = inEdit
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
        
        deletedRecipesIds.removeAll()
    }
    
}

// MARK: - TableView Delegate and Datasource

extension CookbookViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecipes?.count ?? recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as? RecipeTableViewCell else {
            fatalError("cell should be RecipeTableViewCell type")
        }
        
        let recipe = filteredRecipes?[indexPath.row] ?? recipes[indexPath.row]
        
        var lastCookingDateString = "Never Cooked"
        
        if let lastDate = recipe.lastCookingDate {
            lastCookingDateString = UtilsManager.shared.dateFormatter.string(from: lastDate)
        } else if let lastDateString = recipe.cookingDates?.first {
            lastCookingDateString = lastDateString
        }
        
        cell.configure(withName: recipe.name ?? "Not Set", portions: recipe.portions ?? 0, lastCooking: lastCookingDateString, cookingTime: recipe.cookingTime, dificulty: recipe.dificulty, categories: recipe.categories ?? "Not Set", image: recipe.recipeImage)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 193.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecipe = filteredRecipes?[indexPath.row] ?? recipes[indexPath.row]
        
        performSegue(withIdentifier: "recipeDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedRecipesIds.append(filteredRecipes?[indexPath.row].id ?? recipes[indexPath.row].id)
            
            if filteredRecipes != nil {
                filteredRecipes?.remove(at: indexPath.row)
            } else {
                recipes.remove(at: indexPath.row)
            }
            
            recipesTableView.reloadData()
        }
    }
    
}

// MARK: - User Data Manager Delegate

extension CookbookViewController: UserDataManagerDelegate {
    func recipeAdded() {
        populateRecipes()
    }
    
    func recipeChanged() {
        populateRecipes()
    }
    
    func recipeRemoved() {
        populateRecipes()
    }
}

// MARK: - Editing

extension CookbookViewController {
    
    // MARK: Private selectors
    
    @objc private func editPressed() {
        setupScreenMode(inEditMode: true)
    }
    
    @objc private func savePressed() {
        let dispatchGroup = DispatchGroup()
        
        for id in deletedRecipesIds {
            dispatchGroup.enter()
            
            UserDataManager.shared.removeRecipe(withId: id) {
                if let loggedInUser = UsersManager.shared.currentLoggedInUser {
                    loggedInUser.data.recipes?[id] = nil
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

// MARK: - Sorting

extension CookbookViewController {
    
    // MARK: Private helpers
    
    private func sortRecipes(withSortOption option: SortOption?, isAscending: Bool) {
        guard let sortOption = self.selectedSortOption else { return }
        
        var sortedRecipes = filteredRecipes ?? recipes

        sortedRecipes.sort(by: { (r1, r2) -> Bool in
            switch (sortOption, isAscending) {
            case (.name, true):
                if let r1Name = r1.name, let r2Name = r2.name {
                    return r1Name.compare(r2Name) == .orderedAscending
                } else {
                    return false
                }
            case (.name, false):
                if let r1Name = r1.name, let r2Name = r2.name {
                    return r1Name.compare(r2Name) == .orderedDescending
                } else {
                    return false
                }
            case (.cookingTime, true):
                return r1.cookingTimeHours < r2.cookingTimeHours || (r1.cookingTimeHours == r2.cookingTimeHours && r1.cookingTimeMinutes < r2.cookingTimeMinutes)
            case (.cookingTime, false):
                return r1.cookingTimeHours > r2.cookingTimeHours || (r1.cookingTimeHours == r2.cookingTimeHours && r1.cookingTimeMinutes > r2.cookingTimeMinutes)
            case (.dificulty, true):
                if let r1Difficulty = r1.dificulty, let r2Difficulty = r2.dificulty {
                    return r1Difficulty.compare(r2Difficulty) == .orderedAscending
                } else {
                    return false
                }
            case (.dificulty, false):
                if let r1Difficulty = r1.dificulty, let r2Difficulty = r2.dificulty {
                    return r1Difficulty.compare(r2Difficulty) == .orderedDescending
                } else {
                    return false
                }
            case (.portions, true):
                return r1.portions ?? 0 < r2.portions ?? 0
            case (.portions, false):
                return r1.portions ?? 0 > r2.portions ?? 0
            case (.lastCooking, true):
                if let r1LastCookingDate = r1.lastCookingDate, let r2LastCookingDate = r2.lastCookingDate {
                    return r1LastCookingDate.compare(r2LastCookingDate) == .orderedAscending
                } else {
                    return false
                }
            case (.lastCooking, false):
                if let r1LastCookingDate = r1.lastCookingDate, let r2LastCookingDate = r2.lastCookingDate {
                    return r1LastCookingDate.compare(r2LastCookingDate) == .orderedDescending
                } else {
                    return false
                }
            }
        })

        if filteredRecipes != nil {
            filteredRecipes = sortedRecipes
        } else {
            recipes = sortedRecipes
        }

        recipesTableView.reloadData()
    }
    
    private func dismissSortView(discardChanges: Bool) {
        hideButtonsAndTabBar(hide: false)
        
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
        navigationItem.title = "Cookbook"
        
        if discardChanges == false {
            self.sortRecipes(withSortOption: self.selectedSortOption, isAscending: self.isSortAscending)
        }
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
    
    // MARK: Private selectors
    
    @objc private func sortPressed() {
        hideButtonsAndTabBar(hide: true)
        sortBackgroundButtonSetup()
        
        sortView = CookbookSortView(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 200,
                                          height: 250))
        
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
                                         sortView.topAnchor.constraint(equalTo: recipesTableView.topAnchor, constant: 8),
                                         sortView.trailingAnchor.constraint(equalTo: recipesTableView.trailingAnchor, constant: -8),
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

extension CookbookViewController: RecipesFilterViewDelegate {
    
    // MARK: Actions
    
    @IBAction func filterPressed(_ sender: Any) {
        hideButtonsAndTabBar(hide: true)
        
        self.filterView = RecipesFilterView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        self.filterView?.configure(withFilterParams: self.filterParams)
        
        self.filterView?.delegate = self
        
        guard let filterView = self.filterView else { return }
        
        self.displayFilterNavButton()
        
        view.addSubview(filterView)
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([filterView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     filterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     filterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     filterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @objc private func cancelFilterPressed() {
        self.displayCookbookNavButtons()
        
        self.filterView?.removeFromSuperview()
    }
    
    @objc private func resetFilterPressed() {
        self.displayCookbookNavButtons()
        
        filterParams = nil
        filteredRecipes = nil
        
        self.filterView?.removeFromSuperview()
        
        recipesTableView.reloadData()
    }
    
    @objc private func doneFilteringPressed() {
        self.displayCookbookNavButtons()
        
        if let params = self.filterView?.filterParams {
            filterParams = params
        
            filterRecipes(withParams: params)
            
            self.filterView?.removeFromSuperview()
        
            recipesTableView.reloadData()
        }
    }
    
    // MARK: Private helpers
    
    private func filterRecipes(withParams params: RecipeFilterParams) {
        filteredRecipes = nil
        
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            if let category = params.categoryString {
                filteredRecipes = userRecipes.filter({ recipe -> Bool in
                    if let categories = recipe.categories {
                        return categories.contains(category)
                    } else {
                        return false
                    }
                })
            }
            
            if let lastCookingDateString = params.cookingDate {
                let filteringRecipes = filteredRecipes ?? userRecipes
                
                switch lastCookingDateString {
                case .never:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        return recipe.cookingDates == nil
                    })
                case .oneWeek:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
                            for date in recipe.cookingDatesAsDates where !result {
                                result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: oneWeekAgoDate)
                            }
                        }
                        
                        return result
                    })
                case .twoWeeks:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let twoWeeksAgoDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) {
                            for date in recipe.cookingDatesAsDates where !result {
                                result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: twoWeeksAgoDate)
                            }
                        }
                        
                        return result
                    })
                case .oneMonthPlus:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let oneMonthAgoDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) {
                            for date in recipe.cookingDatesAsDates where !result {
                                result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: oneMonthAgoDate)
                            }
                        }
                        
                        return result
                    })
                }
            }
            
            if let portions = params.portions {
                let filteringRecipes = filteredRecipes ?? userRecipes
                
                filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                    switch portions {
                    case .oneOrTwo:
                        return recipe.portions ?? 0 <= 2
                    case .threeOrFour:
                        return recipe.portions ?? 0 == 3 || recipe.portions ?? 0 == 4
                    case .betweenFiveAndEight:
                        return recipe.portions ?? 0 >= 5 && recipe.portions ?? 0 <= 8
                    case .ninePlus:
                        return recipe.portions ?? 0 >= 9
                    }
                })
            }
            
            if let dificulty = params.dificulty {
                let filteringRecipes = filteredRecipes ?? userRecipes
                
                filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                    return recipe.dificulty == dificulty.rawValue
                })
            }
            
            if let cookingTime = params.cookingTime {
                let filteringRecipes = filteredRecipes ?? userRecipes
                
                filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                    switch cookingTime {
                    case .under15Min:
                        return recipe.cookingTimeHours == 0 && (1...15).contains(recipe.cookingTimeMinutes)
                    case .between16And30Mins:
                        return recipe.cookingTimeHours == 0 && (16...30).contains(recipe.cookingTimeMinutes)
                    case .between31And60Mins:
                        return recipe.cookingTimeHours == 0 && (31...60).contains(recipe.cookingTimeMinutes)
                    case .oneHourPlus:
                        return recipe.cookingTimeHours >= 1
                    }
                })
            }
        }
        
        if let selectedSortOption = selectedSortOption {
            sortRecipes(withSortOption: selectedSortOption, isAscending: self.isSortAscending)
        }
    }
    
    // MARK: Delegates
    
    func recipeFilterCanceled() {
        self.displayCookbookNavButtons()
    }
    
}
