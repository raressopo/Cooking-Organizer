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
    
    var recipes = [Recipe]()
    
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

struct UserData: Codable {
    let email: String
    let signUpDate: String
    
    let homeIngredients: [String:HomeIngredient]?
}
