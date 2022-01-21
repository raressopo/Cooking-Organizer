//
//  CookbookViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class CookbookViewController: UIViewController {
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var addRecipeButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    private var recipes = [Recipe]()
    private var filteredRecipes: [Recipe]?
    
    private var selectedRecipe: Recipe?
    
    private var deletedRecipesIds = [String]()
    
    var filterParams: RecipeFilterParams?
    
    var selectedSortOption: SortStackViewButtons?
    
    var sortView: SortView?
    var sortViewDismissBackgroundButton: UIButton?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        recipesTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        
        let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        let sortNavBarButton = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortPressed))
        
        navigationItem.rightBarButtonItems = [sortNavBarButton, editNavBarButton]
        
        populateRecipes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue", let destinationVC = segue.destination as? RecipeDetailsViewControllerv2 {
            destinationVC.recipe = selectedRecipe
            
            selectedRecipe = nil
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        let filterView = RecipesFilterView(withParams: filterParams,
                                           criterias: [.recipeCategory, .cookingDate, .cookingTime, .portions, .difficulty],
                                           andFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.addSubview(filterView)
        
        filterView.delegate = self
        
        filterView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([filterView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     filterView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     filterView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     filterView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    // MARK: - Private Helpers
    
    private func populateRecipes() {
        if let params = filterParams {
            filterRecipes(withParams: params)
        } else {
            if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
                recipes = userRecipes
            }
        }
        
        if let sortOption = selectedSortOption {
            sortRecipes(withSortOption: sortOption)
        }
        
        recipesTableView.reloadData()
    }
    
    private func setupScreenMode(inEditMode inEdit: Bool) {
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
                        return recipe.portions <= 2
                    case .threeOrFour:
                        return recipe.portions == 3 || recipe.portions == 4
                    case .betweenFiveAndEight:
                        return recipe.portions >= 5 && recipe.portions <= 8
                    case .ninePlus:
                        return recipe.portions >= 9
                    }
                })
            }
            
            if let difficulty = params.difficulty {
                let filteringRecipes = filteredRecipes ?? userRecipes
                
                filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                    return recipe.dificulty == difficulty.rawValue
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
            sortRecipes(withSortOption: selectedSortOption)
        }
    }
    
    private func sortRecipes(withSortOption option: SortStackViewButtons) {
        var sortedRecipes = filteredRecipes ?? recipes
        
        sortedRecipes.sort(by: { (r1, r2) -> Bool in
            switch option {
            case .recipeNameAscending:
                if let r1Name = r1.name, let r2Name = r2.name {
                    return r1Name.compare(r2Name) == .orderedAscending
                } else {
                    return false
                }
            case .recipeNameDescending:
                if let r1Name = r1.name, let r2Name = r2.name {
                    return r1Name.compare(r2Name) == .orderedDescending
                } else {
                    return false
                }
            case .cookingTimeAscending:
                return r1.cookingTimeHours < r2.cookingTimeHours || (r1.cookingTimeHours == r2.cookingTimeHours && r1.cookingTimeMinutes < r2.cookingTimeMinutes)
            case .cookingTimeDescending:
                return r1.cookingTimeHours > r2.cookingTimeHours || (r1.cookingTimeHours == r2.cookingTimeHours && r1.cookingTimeMinutes > r2.cookingTimeMinutes)
            case .difficultyAscending:
                if let r1Difficulty = r1.dificulty, let r2Difficulty = r2.dificulty {
                    return r1Difficulty.compare(r2Difficulty) == .orderedAscending
                } else {
                    return false
                }
            case .difficultyDescending:
                if let r1Difficulty = r1.dificulty, let r2Difficulty = r2.dificulty {
                    return r1Difficulty.compare(r2Difficulty) == .orderedDescending
                } else {
                    return false
                }
            case .portionsAscending:
                return r1.portions < r2.portions
            case .portionsDescending:
                return r1.portions > r2.portions
            case .lastCookingDateAscending:
                if let r1LastCookingDate = r1.lastCookingDate, let r2LastCookingDate = r2.lastCookingDate {
                    return r1LastCookingDate.compare(r2LastCookingDate) == .orderedAscending
                } else {
                    return false
                }
            case .lastCookingDateDescending:
                if let r1LastCookingDate = r1.lastCookingDate, let r2LastCookingDate = r2.lastCookingDate {
                    return r1LastCookingDate.compare(r2LastCookingDate) == .orderedDescending
                } else {
                    return false
                }
            default:
                return false
            }
        })
        
        if filteredRecipes != nil {
            filteredRecipes = sortedRecipes
        } else {
            recipes = sortedRecipes
        }
        
        recipesTableView.reloadData()
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
    
    private func dismissSortView() {
        sortView?.removeFromSuperview()
        
        sortView = nil
        
        removeSortBackgroundButton()
    }
    
    // MARK: - Private Selectors
    
    @objc
    private func dismissSortViewBackgroundPressed() {
        dismissSortView()
    }
    
    @objc
    private func editPressed() {
        setupScreenMode(inEditMode: true)
    }
    
    @objc
    private func sortPressed() {
        if let _ = sortView {
            dismissSortView()
        } else {
            sortBackgroundButtonSetup()
            
            sortView = SortView(withButtons: [.recipeNameAscending,
                                              .recipeNameDescending,
                                              .cookingTimeAscending,
                                              .cookingTimeDescending,
                                              .difficultyAscending,
                                              .difficultyDescending,
                                              .portionsAscending,
                                              .portionsDescending,
                                              .lastCookingDateAscending,
                                              .lastCookingDateDescending],
                                andFrame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 250,
                                                 height: 500))
            
            if let sortView = sortView {
                sortView.selectedSortOption = { sortOption in
                    self.selectedSortOption = sortOption
                    
                    self.sortRecipes(withSortOption: sortOption)
                    
                    self.dismissSortView()
                }
                
                sortView.translatesAutoresizingMaskIntoConstraints = false
                
                view.addSubview(sortView)
                
                NSLayoutConstraint.activate([sortView.heightAnchor.constraint(equalToConstant: 500),
                                             sortView.topAnchor.constraint(equalTo: recipesTableView.topAnchor, constant: 10),
                                             sortView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                                             sortView.widthAnchor.constraint(equalToConstant: 250)])
            }
        }
    }
    
    @objc
    private func savePressed() {
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
    
    @objc
    private func cancelPressed() {
        setupScreenMode(inEditMode: false)
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
        
        cell.nameLabel.text = recipe.name
        cell.cookingTimeLabel.text = "Cooking Time: \(recipe.formattedCookingTime)"
        
        var lastCookingDateString = "Never Cooked"
        
        if let lastDate = recipe.lastCookingDate {
            lastCookingDateString = UtilsManager.shared.dateFormatter.string(from: lastDate)
        } else if let lastDateString = recipe.cookingDates?.first {
            lastCookingDateString = lastDateString
        }
        
        cell.lastCookLabel.text = "Last Cook: \(lastCookingDateString)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let recipe = filteredRecipes?[indexPath.row] ?? recipes[indexPath.row]
        
        return 99 - 25 + RecipeTableViewCell.recipeCellHeight(forString: recipe.name ?? "")
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

extension CookbookViewController: FilterViewDelegate {
    func recipeFilterPressed(withParams params: RecipeFilterParams) {
        filterParams = params
        
        filterRecipes(withParams: params)
        
        recipesTableView.reloadData()
    }
    
    func recipeResetFilterPressed() {
        filterParams = nil
        filteredRecipes = nil
        
        recipesTableView.reloadData()
    }
}
