//
//  NewRecipeIngredient.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class NewRecipeIngredient: Codable, Equatable {
    static func == (lhs: NewRecipeIngredient, rhs: NewRecipeIngredient) -> Bool {
        return lhs.name == rhs.name && lhs.quantity == rhs.quantity && lhs.unit == rhs.unit
    }
    
    var name: String?
    var quantity: String?
    var unit: String?
    
    func asDictionary() -> [String:Any] {
        return ["name": name ?? "", "quantity": quantity ?? "", "unit": unit ?? ""]
    }
}

struct CopyOfIngredientRecipe {
    var name: String?
    var quantity: String?
    var unit: String?
    
    func asDictionary() -> [String:Any] {
        return ["name": name ?? "", "quantity": quantity ?? "", "unit": unit ?? ""]
    }
}
