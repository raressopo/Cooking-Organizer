//
//  CookbookWidgetTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 17/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol CookbookWidgetTableViewCellDelegate: class {
    func recipePressed(withRecipe recipe: Recipe)
}

class CookbookWidgetTableViewCell: UITableViewCell {
    @IBOutlet weak var recipesTableView: UITableView!
    
    weak var delegate: CookbookWidgetTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        recipesTableView.register(UINib(nibName: "RecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
    }
}

// MARK: - TableView Delegates and DataSource

extension CookbookWidgetTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipesCount = UsersManager.shared.currentLoggedInUser?.recipes?.count else {
            return 0
        }
        
        return recipesCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell") as? RecipeTableViewCell else {
            fatalError("Cell is not RecipesTableViewCell type")
        }
        
        cell.selectionStyle = .none
        
        if let recipe = UsersManager.shared.currentLoggedInUser?.recipes?[indexPath.row] {
            cell.nameLabel.text = recipe.name
            cell.nrOfIngredientsLabel.text = "\(recipe.ingredientsCountAsString) ingrds."
            cell.cookingTimeLabel.text = recipe.cookingTime
            cell.categoriesLabel.text = recipe.categories
            cell.portionsLabel.text = "\(recipe.portions)"
            cell.lastCookLabel.text = recipe.lastCook ?? "Never Cooked"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let recipe = UsersManager.shared.currentLoggedInUser?.recipes?[indexPath.row] {
            delegate?.recipePressed(withRecipe: recipe)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

extension CookbookWidgetTableViewCell: UserDataManagerDelegate {
    func recipeChanged() {
        recipesTableView.reloadData()
    }
}
