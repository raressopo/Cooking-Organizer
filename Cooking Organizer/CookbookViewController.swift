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
    
    private var recipes = [Recipe]()
    
    private var selectedRecipe: Recipe?
    
    private var deletedRecipesIds = [String]()
    
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
    
    // MARK: - Private Helpers
    
    private func populateRecipes() {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipes = userRecipes
            
            recipesTableView.reloadData()
        }
    }
    
    private func setupScreenMode(inEditMode inEdit: Bool) {
        populateRecipes()
        
        recipesTableView.setEditing(inEdit, animated: true)
        
        navigationItem.hidesBackButton = inEdit
        addRecipeButton.isHidden = inEdit
        
        if inEdit {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
            navigationItem.leftBarButtonItem = nil
        }
        
        deletedRecipesIds.removeAll()
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
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        
        let recipe = recipes[indexPath.row]
        
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
        selectedRecipe = recipes[indexPath.row]
        
        performSegue(withIdentifier: "recipeDetailsSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deletedRecipesIds.append(recipes[indexPath.row].id)
            recipes.remove(at: indexPath.row)
            
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
