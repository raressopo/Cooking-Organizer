//
//  RecipeDetailsViewControllerv2.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsViewControllerv2: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var portionsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var lastCookLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        if let data = recipe.imageData {
            let dataDecode = Data(base64Encoded: data, options: .ignoreUnknownCharacters)
            
            if let imageData = dataDecode {
                let decodedImage = UIImage(data: imageData)
                
                imageView.image = decodedImage
            }
        }
        
        recipeTitle.text = recipe.name
        portionsLabel.text = "Portions: \(recipe.portions)"
        durationLabel.text = "Duration: \(recipe.cookingTime ?? "Undefined")"
        difficultyLabel.text = "Difficulty: \(recipe.dificulty ?? "Undefined")"
        lastCookLabel.text = "Last Cook: \(recipe.cookingDates?.first ?? "Undefined")"
        categoriesLabel.text = "Categries: \(recipe.categories ?? "Undefined")"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ingredientsSegue", let destinationVC = segue.destination as? IngredientsViewController {
            if let recipeIngredients = recipe?.ingredients, recipeIngredients.count > 0 {
                destinationVC.ingredients = recipeIngredients
            }
        } else if segue.identifier == "stepsSegue", let destinationVC = segue.destination as? StepsViewController {
            if let recipeSteps = recipe?.steps, recipeSteps.count > 0 {
                destinationVC.steps = recipeSteps
                destinationVC.recipe = recipe
            }
        }
    }
    
    @IBAction func ingredientsPressed(_ sender: Any) {
    }
    
    @IBAction func stepsPressed(_ sender: Any) {
    }
}
