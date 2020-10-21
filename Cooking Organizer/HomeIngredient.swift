//
//  HomeIngredient.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class HomeIngredient: Codable {
    let id: String
    var name: String?
    var expirationDate: String?
    var quantity: Double?
    var unit: String?
    var category: String?
    
    var quantityAsString: String {
        if let quantity = quantity {
            return "\(quantity)"
        } else {
            return ""
        }
    }
    
    var expirationDateAsDate: Date? {
        if let expDate = expirationDate {
            return UtilsManager.shared.dateFormatter.date(from: expDate)
        } else {
            return nil
        }
    }
}
