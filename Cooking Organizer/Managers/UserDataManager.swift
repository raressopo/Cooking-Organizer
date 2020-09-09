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
    func userDataDidFetch()
    func homeIngredientsChanged()
    func homeIngredientsAdded()
    
    func recipeAdded()
}

extension UserDataManagerDelegate {
    func userDataDidFetch() {}
    func homeIngredientsChanged() {}
    func homeIngredientsAdded() {}
    
    func recipeAdded() {}
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    weak var delegate: UserDataManagerDelegate?
    
    var isInitialHomeIngredientsfetchFinished = false
    
//    func observeHomeIngredientsAdded(forUserId id: String, ingredientAdded: @escaping () -> Void, onFailure: @escaping () -> Void) {
//        Database.database().reference().child("usersData").child(id).child("homeIngredients").observe(.childAdded) { (snapshot) in
//            guard let currentUser = UsersManager.shared.currentLoggedInUser else {
//                onFailure()
//                
//                return
//            }
//            
//            if currentUser.homeIngredients.contains(where: { (ingredient) -> Bool in
//                return ingredient.id == snapshot.key
//            }) {
//                onFailure()
//                
//                return
//            }
//            
//            let homeIngredient = HomeIngredient()
//            
//            homeIngredient.id = snapshot.key
//            
//            if let homeIngredientDetails = snapshot.value as? [String:Any] {
//                homeIngredient.name = homeIngredientDetails["name"] as? String
//                homeIngredient.expirationDate = homeIngredientDetails["expirationDate"] as? String
//                homeIngredient.quantity = homeIngredientDetails["quantity"] as? Double
//                homeIngredient.unit = homeIngredientDetails["unit"] as? String
//                homeIngredient.categoriesAsString = homeIngredientDetails["categories"] as? String
//            }
//            
//            currentUser.homeIngredients.append(homeIngredient)
//            
//            ingredientAdded()
//            self.delegate?.homeIngredientsAdded()
//        }
//    }
//    
//    func observeHomeIngredientChanged(forUserId id: String, onFailure: @escaping () -> Void) {
//        Database.database().reference().child("usersData").child(id).child("homeIngredients").observe(.childChanged) { (snapshot) in
//            guard let currentUser = UsersManager.shared.currentLoggedInUser else {
//                onFailure()
//                
//                return
//            }
//            
//            guard let changedIngredient = currentUser.homeIngredients.first(where: { (ingredient) -> Bool in
//                return ingredient.id == snapshot.key
//            }) else {
//                onFailure()
//                
//                return
//            }
//            
//            guard let changes = snapshot.value as? [String:Any] else {
//                onFailure()
//                
//                return
//            }
//            
//            if let name = changes["name"] as? String {
//                changedIngredient.name = name
//            }
//            
//            if let expirationDate = changes["expirationDate"] as? String {
//                changedIngredient.expirationDate = expirationDate
//            }
//            
//            if let quantity = changes["quantity"] as? Double {
//                changedIngredient.quantity = quantity
//            }
//            
//            if let unit = changes["unit"] as? String {
//                changedIngredient.unit = unit
//            }
//            
//            if let categories = changes["categories"] as? String {
//                changedIngredient.categoriesAsString = categories
//            }
//            
//            self.delegate?.homeIngredientsChanged()
//        }
//    }
    
    func observeRecipeAdded(forUserId id: String, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) {
        Database.database().reference().child("usersData").child(id).child("recipes").observe(.childAdded) { snapshot in
            guard let currentUser = UsersManager.shared.currentLoggedInUser else {
                onFailure()
                
                return
            }
            
            if currentUser.recipes.contains(where: { recipe -> Bool in
                return recipe.id == snapshot.key
            }) {
                onFailure()
                
                return
            }
            
            let recipe = Recipe()
            
            recipe.id = snapshot.key
            
            guard let recipeDetails = snapshot.value as? [String:Any] else {
                onFailure()
                
                return
            }
            
            if let recipeImageData = recipeDetails["imageData"] as? String {
                let dataDecode = Data(base64Encoded: recipeImageData, options: .ignoreUnknownCharacters)
                
                if let imageData = dataDecode {
                    let decodedImage = UIImage(data: imageData)
                    
                    recipe.image = decodedImage
                }
            }
            
            recipe.name = recipeDetails["name"] as? String ?? nil
            
            if let portions = recipeDetails["portions"] as? NSNumber {
                recipe.portions = portions.intValue
            }
            
            recipe.cookingTime = recipeDetails["cookingTime"] as? String ?? nil
            recipe.dificulty = recipeDetails["dificulty"] as? String ?? nil
            recipe.lastCook = recipeDetails["lastCook"] as? String ?? nil
            recipe.categoriesAsString = recipeDetails["categories"] as? String ?? nil
            
            if let ingredientsDetails = recipeDetails["ingredients"] as? [Any] {
                ingredientsDetails.forEach { value in
                    if let ingredientDict = value as? [String:Any] {
                        let ingredient = NewRecipeIngredient()
                        
                        ingredient.name = ingredientDict["name"] as? String
                        ingredient.quantityAsString = ingredientDict["quantity"] as? String
                        ingredient.unit = ingredientDict["unit"] as? String
                        
                        recipe.ingredients.append(ingredient)
                    }
                }
            }
            
            if let stepsDetails = recipeDetails["steps"] as? [String] {
                stepsDetails.forEach { value in
                    if let index = stepsDetails.firstIndex(of: value) {
                        recipe.steps.insert(value, at: index)
                    }
                }
            }
            
            currentUser.recipes.append(recipe)
            self.delegate?.recipeAdded()
            
            onSuccess()
        }
    }
}
