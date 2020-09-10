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
    var lastCook: String?
    var name: String?
    var portions: Int = 0
    
    var ingredients: [NewRecipeIngredient]?
    var steps: [String]?
}
