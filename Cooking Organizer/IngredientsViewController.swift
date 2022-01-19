//
//  IngredientsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class IngredientsViewController: UIViewController {
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var addIngredientButton: UIButton!
    
    @IBOutlet weak var ingredientsTableViewBottomToButtonConstraint: NSLayoutConstraint!
    
    var ingredients = [NewRecipeIngredient]()
    var ingredientsCopy = [NewRecipeIngredient]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        
        ingredientsTableView.register(UINib(nibName: "RecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "ingredientCell")
        ingredientsTableView.register(UINib(nibName: "ChangeRecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "changeIngredientCell")
        
        ingredientsTableViewBottomToButtonConstraint.isActive = false
        addIngredientButton.isHidden = true
        
        ingredientsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @IBAction func addIngredientPressed(_ sender: Any) {
    }
}

extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ingredient = ingredients[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as? RecipeIngredientCell else {
            fatalError("Cell type is not RecipeIngredientCell")
        }
        
        cell.nameLabel.text = ingredient.name
        
        if let quantity = ingredient.quantity,
           let unit = ingredient.unit {
            cell.quantityUnitLabel.text = quantity + " " + unit
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
