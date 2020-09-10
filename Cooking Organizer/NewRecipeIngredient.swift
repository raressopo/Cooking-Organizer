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
    
    var quantityAsString: String?
//    {
//        didSet {
//            if let qtAsString = quantityAsString,
//                let quantityAsNumber = NumberFormatter().number(from: qtAsString) {
//                quantity = quantityAsNumber.doubleValue
//            }
//        }
//    }
    
    func asDictionary() -> [String:Any] {
        return ["name": name ?? "", "quantity": quantityAsString ?? "", "unit": unit ?? ""]
    }
}
