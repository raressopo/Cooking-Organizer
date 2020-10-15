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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        recipesTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        
        populateRecipes()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue", let destinationVC = segue.destination as? RecipeDetailsViewController {
            destinationVC.recipe = selectedRecipe
            
            selectedRecipe = nil
        }
    }
    
    @IBAction func filterPressed(_ sender: Any) {
        let filterView = RecipesFilterView(withParams: filterParams, criterias: [.RecipeCategory, .CookingDate, .CookingTime, .Portions, .Difficulty], andFrame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
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
        
        recipesTableView.reloadData()
    }
    
    private func setupScreenMode(inEditMode inEdit: Bool) {
        populateRecipes()
        
        recipesTableView.setEditing(inEdit, animated: true)
        
        navigationItem.hidesBackButton = inEdit
        addRecipeButton.isHidden = inEdit
        filterButton.isHidden = inEdit
        
        if inEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
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
                case .Never:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        return recipe.cookingDates == nil
                    })
                    
                    break
                case .OneWeek:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let oneWeekAgoDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) {
                            for date in recipe.cookingDatesAsDates {
                                if !result {
                                    result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: oneWeekAgoDate)
                                }
                            }
                        }
                        
                        return result
                    })
                    
                    break
                case .TwoWeeks:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let twoWeeksAgoDate = Calendar.current.date(byAdding: .day, value: -14, to: Date()) {
                            for date in recipe.cookingDatesAsDates {
                                if !result {
                                    result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: twoWeeksAgoDate)
                                }
                            }
                        }
                        
                        return result
                    })
                    
                    break
                case .OneMonthPlus:
                    filteredRecipes = filteringRecipes.filter({ recipe -> Bool in
                        var result = false
                        
                        if let oneMonthAgoDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) {
                            for date in recipe.cookingDatesAsDates {
                                if !result {
                                    result = UtilsManager.isSelectedDate(selectedDate: date, inFutureOrInPresentToGivenDate: oneMonthAgoDate)
                                }
                            }
                        }
                        
                        return result
                    })
                    
                    break
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
    }
    
    // MARK: - Private Selectors
    
    @objc
    private func editPressed() {
        setupScreenMode(inEditMode: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        
        let recipe = filteredRecipes?[indexPath.row] ?? recipes[indexPath.row]
        
        cell.nameLabel.text = recipe.name
        cell.categoriesLabel.text = recipe.categories
        cell.cookingTimeLabel.text = recipe.cookingTime
        cell.lastCookLabel.text = recipe.cookingDates != nil ? "" : "Never Cooked"
        
        if let ingredients = recipe.ingredients {
            cell.nrOfIngredientsLabel.text = "\(ingredients.count) ingr."
        }
        
        cell.portionsLabel.text = "\(recipe.portions) portions"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecipe = filteredRecipes?[indexPath.row] ?? recipes[indexPath.row]
        
        performSegue(withIdentifier: "recipeDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedRecipesIds.append(filteredRecipes?[indexPath.row].id ?? recipes[indexPath.row].id)
            
            if let _ = filteredRecipes {
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
