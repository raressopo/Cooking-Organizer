//
//  User.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class User: NSObject {
    var email: String?
    var password: String?
    
    var id: String?
    
    var signUpDate: String? // TODO: Transform it into Date later
    
    var homeIngredients = [HomeIngredient]()
}
