//
//  Recipe.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    var image: UIImage?
    
    var name: String?
    
    var portions: Int = 0
    var cookingTime: String?
    
    var dificulty: String?
    var lastCook: String?
    
    var categoriesAsString: String?
    
    var ingredients = [NewRecipeIngredient]()
    
    var steps = [String]()
    
    var id: String?
}
