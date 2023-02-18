//
//  NewRecipe.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/10/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

struct NewRecipe {
    let recipeName: String
    let portionsAsString: String?
    let cookingTimeHours: Int?
    let cookingTimeMinutes: Int?
    let difficulty: String?
    let lastCookDateString: String?
    let categoriesAsString: String
    let recipePhoto: UIImage?
    let ingredients: [NewRecipeIngredient]?
    let steps: [String]?
    let id: String
    
    func asDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        
        dictionary["name"] = self.recipeName
        dictionary["categories"] = self.categoriesAsString
        dictionary["id"] = id
        
        if let portions = portionsAsString, let portionsNumber = NumberFormatter().number(from: portions) {
            dictionary["portions"] = portionsNumber
        }
        
        if let cookingTimeHours = self.cookingTimeHours, cookingTimeHours == 0,
           let cookingTimeMinutes = self.cookingTimeMinutes , cookingTimeMinutes == 0 {
            dictionary["cookingTime"] = "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes"
        }
        
        if let dificulty = self.difficulty, dificulty.isEmpty == false {
            dictionary["dificulty"] = dificulty
        }
        
        if let lastCookDate = self.lastCookDateString, lastCookDate.isEmpty == false {
            dictionary["cookingDates"] = [lastCookDate]
        }
        
        if let ingredients = self.ingredients, ingredients.count > 0 {
            var ingredientsDictionary = [String: Any]()
            
            ingredients.forEach { ingredientsDictionary["\(ingredients.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
            
            dictionary["ingredients"] = ingredientsDictionary
        }
        
        if let steps = self.steps, steps.count > 0 {
            var stepsDictionary = [String: Any]()
            
            steps.forEach { stepsDictionary["\(steps.firstIndex(of: $0) ?? 0)"] = $0 }
            
            dictionary["steps"] = stepsDictionary
        }
        
        return dictionary
    }
}
