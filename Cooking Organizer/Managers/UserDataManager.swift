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
    
    func addNewHomeIngredient(withDetails details: [String:Any],
                              success: @escaping () -> Void,
                              failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.addHomeIngredient(withDetails: details,
                                                            success: success,
                                                            failure: failure)
    }
    
    func changeHomeIngredient(withId id: String,
                              andDetails details: [String:Any],
                              success: @escaping () -> Void,
                              failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeHomeIngrdient(withId: id,
                                                              andDetails: details,
                                                              success: success,
                                                              failure: failure)
    }
    
    func changeLastCook(forRecipeId recipeId: String, withValue value: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeLastCook(forRecipeId: recipeId,
                                                         withValue: value,
                                                         success: success,
                                                         failure: failure)
    }
}
