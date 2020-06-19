//
//  Recipe.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class Recipe: NSObject {
    var name: String?
    var image: UIImage?
    var portions: Int = 0
    var cookingTime: String?
    var dificulty: String?
    var lastCook: String?
    var categoriesAsString: String?
    var ingredients = [NewRecipeIngredient]()
    var steps = [String]()
    var id: String?
}
