//
//  Recipe.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class Recipe: Codable {
    let id: String
    
    var categories: String?
    var cookingTime: String?
    var dificulty: String?
    var imageData: String?
    var name: String?
    var portions: Int = 0
    
    var cookingDates: [String]?
    var ingredients: [NewRecipeIngredient]?
    var steps: [String]?
    
    var ingredientsCountAsString: String {
        if let ingredientsCount = ingredients?.count {
            return "\(ingredientsCount)"
        } else {
            return "\(0)"
        }
    }
}

class ChangedRecipe {
    var categories: String?
    var cookingTime: String?
    var dificulty: String?
    var imageData: String?
    var name: String?
    var portions: Int = 0
    
    var ingredients: [NewRecipeIngredient]?
    var steps: [String]?
}

struct CookingCalendarRecipe {
    var name: String
    var id: String
    var cookingDates: [String]
}
