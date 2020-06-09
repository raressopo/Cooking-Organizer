//
//  HomeIngredient.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class HomeIngredient: NSObject {
    var id: String?
    var name: String?
    var expirationDate: String?
    var quantity: Double?
    var unit: String?
    var categoriesAsString: String?
    
    var categories: [IngredientCategories] {
        if let categoriesAsString = categoriesAsString {
            let categoriesStringArray = categoriesAsString.components(separatedBy: ", ")
            
            var result = [IngredientCategories]()
            
            IngredientCategories.allCases.forEach { (category) in
                for categoryString in categoriesStringArray {
                    if categoryString == category.string {
                        result.append(category)
                    }
                }
            }
            
            return result
        } else {
            return [IngredientCategories]()
        }
    }
}
