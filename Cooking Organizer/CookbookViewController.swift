//
//  CookbookViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class CookbookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserDataManagerDelegate {
    @IBOutlet weak var recipesTableView: UITableView!
    
    private var recipes = [Recipe]()
    
    private var selectedRecipe: Recipe?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        recipesTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
        
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipes = userRecipes
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recipeDetailsSegue", let destinationVC = segue.destination as? RecipeDetailsViewController {
            destinationVC.recipe = selectedRecipe
            
            selectedRecipe = nil
        }
    }
    
    // MARK: - TableView Delegate and Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        
        let recipe = recipes[indexPath.row]
        
        cell.nameLabel.text = recipe.name
        cell.categoriesLabel.text = recipe.categoriesAsString
        cell.cookingTimeLabel.text = recipe.cookingTime
        cell.lastCookLabel.text = recipe.lastCook
        cell.nrOfIngredientsLabel.text = "\(recipe.ingredients.count) ingr."
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
    
    func recipeAdded() {
        recipesTableView.reloadData()
    }
}
