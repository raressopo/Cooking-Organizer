//
//  RecipeDetailsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    var recipe: Recipe?

    @IBOutlet weak var recipeNametextField: UITextField!
    @IBOutlet weak var portionsTextField: UITextField!
    @IBOutlet weak var cookingTimeTextField: UITextField!
    @IBOutlet weak var dificultyTextField: UITextField!
    @IBOutlet weak var lastCookTextField: UITextField!
    @IBOutlet weak var categoriesTextField: UITextField!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet weak var ingredientsStackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recipeImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewsAndFieldsSetup()
        
        ingredientsStackView.distribution = .fillEqually
        
        ingredientsViewSetup()
    }
    
    private func viewsAndFieldsSetup() {
        recipeImageView.image = recipe?.image
        
        recipeNametextField.text = recipe?.name
        portionsTextField.text = "\(recipe?.portions ?? 0)"
        cookingTimeTextField.text = recipe?.cookingTime
        dificultyTextField.text = recipe?.dificulty
        lastCookTextField.text = recipe?.lastCook
        categoriesTextField.text = recipe?.categoriesAsString
        
        recipeNametextField.isEnabled = false
        portionsTextField.isEnabled = false
        cookingTimeTextField.isEnabled = false
        dificultyTextField.isEnabled = false
        lastCookTextField.isEnabled = false
        categoriesTextField.isEnabled = false
    }
    
    private func ingredientsViewSetup() {
        if let ingredients = recipe?.ingredients {
            ingredients.forEach { (ingredient) in
                let ingredientView = RecipeDetailsIngredientView()
                
                ingredientView.ingredientName.text = ingredient.name
                
                if let quantity = ingredient.quantityAsString, let unit = ingredient.unit {
                    ingredientView.quantityAndUnit.text = quantity + unit
                }
                
                ingredientsStackView.addArrangedSubview(ingredientView)
                
                ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 60.0
            }
        }
    }
}
