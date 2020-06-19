//
//  NewRecipeIngredient.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class NewRecipeIngredient: NSObject {
    var name: String?
    var quantityAsString: String? {
        didSet {
            if let qtAsString = quantityAsString,
                let quantityAsNumber = NumberFormatter().number(from: qtAsString) {
                quantity = quantityAsNumber.doubleValue
            }
        }
    }
    var quantity: Double?
    var unit: String?
    
    func asDictionary() -> [String:Any] {
        return ["name": name ?? "", "quantity": quantityAsString ?? "", "unit": unit ?? ""]
    }
}
