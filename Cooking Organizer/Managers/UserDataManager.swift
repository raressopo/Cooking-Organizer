//
//  UserDataManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

protocol UserDataManagerDelegate: class {
    func homeIngredientsChanged()
    func homeIngredientsAdded()
    
    func recipeAdded()
    func recipeChanged()
}

extension UserDataManagerDelegate {
    func homeIngredientsChanged() {}
    func homeIngredientsAdded() {}
    
    func recipeAdded() {}
    func recipeChanged() {}
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    
    weak var delegate: UserDataManagerDelegate?
    
    func observeHomeIngredientAdded(forUserId id: String) {
        FirebaseAPIManager.sharedInstance.observeHomeIngredientAdded(forUserId: id) { ingredient in
            if let currentUser = UsersManager.shared.currentLoggedInUser, let newIngredient = ingredient {
                currentUser.data.homeIngredients?[newIngredient.id] = newIngredient
                
                self.delegate?.homeIngredientsAdded()
            }
        }
    }
    
    func observeHomeIngredientChanged(forUserId id: String) {
        FirebaseAPIManager.sharedInstance.observeHomeIngredientChanged(forUserId: id) { ingredient in
            if let currentUser = UsersManager.shared.currentLoggedInUser, let changedIngredient = ingredient {
                currentUser.data.homeIngredients?[changedIngredient.id] = changedIngredient
                
                self.delegate?.homeIngredientsChanged()
            }
        }
    }
    
    func observeRecipeAdded(forUserId id: String) {
        FirebaseAPIManager.sharedInstance.observeRecipeAdded(forUserId: id) { recipe in
            if let currentUser = UsersManager.shared.currentLoggedInUser, let newRecipe = recipe {
                currentUser.data.recipes?[newRecipe.id] = newRecipe
                
                self.delegate?.recipeAdded()
            }
        }
    }
    
    func observeRecipeChanged(forUserId id: String) {
        FirebaseAPIManager.sharedInstance.observeRecipeChanged(forUserId: id) { recipe in
            if let currentUser = UsersManager.shared.currentLoggedInUser, let changedRecipe = recipe {
                currentUser.data.recipes?[changedRecipe.id] = changedRecipe
                
                self.delegate?.recipeChanged()
            }
        }
    }
}
