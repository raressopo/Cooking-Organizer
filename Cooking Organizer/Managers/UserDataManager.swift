//
//  UserDataManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol UserDataManagerDelegate: class {
    func userDataDidFetch()
    func homeIngredientsChanged()
}

extension UserDataManagerDelegate {
    func userDataDidFetch() {}
    func homeIngredientsChanged() {}
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    weak var delegate: UserDataManagerDelegate?
    
    var isInitialHomeIngredientsfetchFinished = false
    
    override init() {
        super.init()
    }
    
    func fetchUserDataForUserID(id: String, completion: @escaping (_ succes: Bool) -> Void) {
        Database.database().reference().child("usersData").child(id).observe(.value) { (snapshot) in
            let existingCurrentUser = UsersManager.shared.allUsers.first { (user) -> Bool in
                if let userId = user.id {
                    return userId == id
                } else {
                    return false
                }
            }
            
            guard let currentUserDetails = snapshot.value as? [String: Any], let currentUser = existingCurrentUser else {
                // ALERT
                completion(false)
                return
            }
            
            if let signUpDate = currentUserDetails["signUpDate"] as? String {
                currentUser.signUpDate = signUpDate
            }
            
            completion(true)
            
            self.isInitialHomeIngredientsfetchFinished = true
        }
    }
    
    func observeHomeIngredientsAdded(forUserId id: String, ingredientAdded: @escaping () -> Void) {
        Database.database().reference().child("usersData").child(id).child("homeIngredients").observe(.childAdded) { (snapshot) in
            let existingCurrentUser = UsersManager.shared.allUsers.first { (user) -> Bool in
                if let userId = user.id {
                    return userId == id
                } else {
                    return false
                }
            }
            
            if existingCurrentUser?.homeIngredients.contains(where: { (ingredient) -> Bool in
                return ingredient.id == snapshot.key
            }) ?? false {
                return
            }
            
            guard let currentUser = existingCurrentUser else {
                // ALERT
                return
            }
            
            let homeIngredient = HomeIngredient()
            
            homeIngredient.id = snapshot.key
            
            if let homeIngredientDetails = snapshot.value as? [String:Any] {
                homeIngredient.name = homeIngredientDetails["name"] as? String
                homeIngredient.expirationDate = homeIngredientDetails["expirationDate"] as? String
                homeIngredient.quantity = homeIngredientDetails["quantity"] as? Double
                homeIngredient.unit = homeIngredientDetails["unit"] as? String
                homeIngredient.categoriesAsString = homeIngredientDetails["categories"] as? String
            }
            
            currentUser.homeIngredients.append(homeIngredient)
            
            ingredientAdded()
        }
    }
    
    func observeHomeIngredientChanged(forUserId id: String) {
        Database.database().reference().child("usersData").child(id).child("homeIngredients").observe(.childChanged) { (snapshot) in
            let existingCurrentUser = UsersManager.shared.allUsers.first { (user) -> Bool in
                if let userId = user.id {
                    return userId == id
                } else {
                    return false
                }
            }
            
            guard let currentUser = existingCurrentUser else {
                // ALERT
                return
            }
            
            guard let changedIngredient = currentUser.homeIngredients.first(where: { (ingredient) -> Bool in
                return ingredient.id == snapshot.key
            }) else {
                // ERROR
                return
            }
            
            guard let changes = snapshot.value as? [String:Any] else {
                // ERROR
                return
            }
            
            if let name = changes["name"] as? String {
                changedIngredient.name = name
            }
            
            if let expirationDate = changes["expirationDate"] as? String {
                changedIngredient.expirationDate = expirationDate
            }
            
            if let quantity = changes["quantity"] as? Double {
                changedIngredient.quantity = quantity
            }
            
            if let unit = changes["unit"] as? String {
                changedIngredient.unit = unit
            }
            
            if let categories = changes["categories"] as? String {
                changedIngredient.categoriesAsString = categories
            }
            
            self.delegate?.homeIngredientsChanged()
        }
    }
}
