//
//  ShoppingListItem.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class ShoppingListItem: Codable {
    var name: String?
    var quantity: Double?
    var unit: String?
    var bought: Bool
}
