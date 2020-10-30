//
//  User.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class User: NSObject {
    var loginData: UserLoginData
    var data: UserData
    
    var recipes: [Recipe]? {
        if let recipes = data.recipes {
            return Array(recipes.values)
        } else {
            return nil
        }
    }
    
    var homeIngredients: [HomeIngredient]? {
        if let ingredients = data.homeIngredients {
            return Array(ingredients.values)
        } else {
            return nil
        }
    }
    
    var shoppingListsArray: [ShoppingList]? {
        if let lists = data.shoppingLists {
            return Array(lists.values)
        } else {
            return nil
        }
    }
    
    init(loginData: UserLoginData, data: UserData) {
        self.loginData = loginData
        self.data = data
    }
}

struct UserLoginData: Codable {
    let id: String
    let email: String
    let password: String
}

class UserData: Codable {
    let email: String
    let signUpDate: String
    
    var homeIngredients: [String:HomeIngredient]?
    var recipes: [String:Recipe]?
    
    var shoppingLists: [String:ShoppingList]?
}
