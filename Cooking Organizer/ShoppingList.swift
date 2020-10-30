//
//  ShoppingList.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class ShoppingList: Codable {
    var name: String?
    var items: [String:ShoppingListItem]?
    
    var itemsArray: [ShoppingListItem]? {
        if let itemsDict = items {
            return Array(itemsDict.values)
        } else {
            return nil
        }
    }
}
