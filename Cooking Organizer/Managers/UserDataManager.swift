//
//  UserDataManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 21/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

protocol UserDataManagerDelegate: AnyObject {
    func homeIngredientsChanged()
    func homeIngredientsAdded()
    func homeIngredientRemoved()
    
    func recipeAdded()
    func recipeChanged()
    func recipeRemoved()
    
    func shoppingListsChanged()
}

extension UserDataManagerDelegate {
    func homeIngredientsChanged() {}
    func homeIngredientsAdded() {}
    func homeIngredientRemoved() {}
    
    func recipeAdded() {}
    func recipeChanged() {}
    func recipeRemoved() {}
    
    func shoppingListsChanged() {}
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    
    weak var delegate: UserDataManagerDelegate?
    weak var homeIngredientDelegate: UserDataManagerDelegate?
    weak var shoppingListsDelegate: UserDataManagerDelegate?
    
    func observeHomeIngredientAdded(forUserId id: String) {
        FirebaseAPIManager.sharedInstance.observeHomeIngredientAdded(forUserId: id) { ingredient in
            if let currentUser = UsersManager.shared.currentLoggedInUser, let newIngredient = ingredient {
                currentUser.data.homeIngredients?[newIngredient.id] = newIngredient
                
                self.delegate?.homeIngredientsAdded()
                self.homeIngredientDelegate?.homeIngredientsAdded()
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
    
    func observeHomeIngredientRemoved() {
        FirebaseAPIManager.sharedInstance.observeHomeIngredientRemoved {
            self.delegate?.homeIngredientRemoved()
        }
    }
    
    func observeRecipeRemoved() {
        FirebaseAPIManager.sharedInstance.observeRecipeRemoved {
            self.delegate?.recipeRemoved()
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
    
    func addNewHomeIngredient(withDetails details: [String: Any],
                              success: @escaping () -> Void,
                              failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.addHomeIngredient(withDetails: details,
                                                            success: success,
                                                            failure: failure)
    }
    
    func changeHomeIngredient(withId id: String,
                              andDetails details: [String: Any],
                              success: @escaping () -> Void,
                              failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeHomeIngrdient(withId: id,
                                                              andDetails: details,
                                                              success: success,
                                                              failure: failure)
    }
    
    func changeCookingDates(forRecipeId recipeId: String, withValue value: [String], success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeCookingDates(forRecipeId: recipeId,
                                                             withValue: value,
                                                             success: success,
                                                             failure: failure)
    }
    
    func removeHomeIngredient(withId id: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.removeHomeIngredient(withId: id,
                                                               success: success,
                                                               failure: failure)
    }
    
    func removeRecipe(withId id: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.removeHomeIngredient(withId: id,
                                                               success: success,
                                                               failure: failure)
    }
    
    func getCustomIngredients() {
        FirebaseAPIManager.sharedInstance.getCustomIngredients()
    }
    
    func createShoppingList(withName name: String,
                            andValues values: [String: Any],
                            success: @escaping () -> Void,
                            failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.createShoppingList(withName: name,
                                                             andValues: values,
                                                             success: success,
                                                             failure: failure)
    }
    
    func observeShoppingListsChanged() {
        FirebaseAPIManager.sharedInstance.observeShoppingListsChanged {
            self.delegate?.shoppingListsChanged()
            self.shoppingListsDelegate?.shoppingListsChanged()
        }
    }
    
    func changeShoppingListName(listName oldName: String, withNewName newName: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeShoppingListName(listName: oldName,
                                                                 withNewName: newName,
                                                                 success: success,
                                                                 failure: failure)
    }
    
    func removeShoppingList(withName name: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.removeShoppingList(withName: name,
                                                             success: success,
                                                             failure: failure)
    }
    
    func addShoppingListItem(onList listName: String, withName itemName: String, andValues values: [String: Any], success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.addShoppingListItem(onList: listName,
                                                              withName: itemName,
                                                              andValues: values,
                                                              success: success,
                                                              failure: failure)
    }
    
    func removeShoppingListItem(fromList listName: String, withItemName itemName: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.removeShoppingListItem(fromList: listName,
                                                                 withItemName: itemName,
                                                                 success: success,
                                                                 failure: failure)
    }
    
    func changeShoppingListItem(fromList listName: String, withItemName itemName: String, andValues values: [String: Any], success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.changeShoppingListItem(fromList: listName,
                                                                 withItemName: itemName,
                                                                 andValues: values,
                                                                 success: success,
                                                                 failure: failure)
    }
    
    func markShoppingListAsBought(fromList listName: String, forItem itemName: String, bought: Bool, success: @escaping () -> Void, failure: @escaping () -> Void) {
        FirebaseAPIManager.sharedInstance.markShoppingListAsBought(fromList: listName,
                                                                   forItem: itemName,
                                                                   bought: bought,
                                                                   success: success,
                                                                   failure: failure)
    }
}
