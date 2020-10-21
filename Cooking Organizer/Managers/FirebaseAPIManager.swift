//
//  APIManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 09/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class FirebaseAPIManager {
    static let sharedInstance = FirebaseAPIManager()
    
    private let usersDataRef = Database.database().reference().child("usersData")
    private let usersLoginDataRef = Database.database().reference().child("usersLoginData")
    
    func validateUser(withEmail email: String, andCompletionHandler completion: @escaping (_ loginData: UserLoginData?) -> Void) {
        usersLoginDataRef.child(email).observeSingleEvent(of: .value) { snapshot in
            guard let loginDetails = snapshot.value else {
                completion(nil)
                
                return
            }
            
            do {
                let loginData = try FirebaseDecoder().decode(UserLoginData.self, from: loginDetails)
                
                completion(loginData)
            } catch let error {
                completion(nil)
                
                print(error)
            }
        }
    }
    
    func getUser(withId id: String, loginData: UserLoginData, andCompletionHandler completion: @escaping (_ user: User?) -> Void) {
        usersDataRef.child(id).observeSingleEvent(of: .value) { snapshot in
            guard let userDetails = snapshot.value else {
                completion(nil)
                
                return
            }
            
            do {
                let userData = try FirebaseDecoder().decode(UserData.self, from: userDetails)
                
                completion(User(loginData: loginData, data: userData))
            } catch let error {
                completion(nil)
                
                print(error)
            }
        }
    }
    
    func createUser(withDetails details: [String:Any],
                    andLoginDetails loginDetails: [String:Any],
                    success: @escaping (Bool) -> Void) {
        
        guard let loginEmail = loginDetails["email"] as? String,
            let id = loginDetails["id"] as? String else
        {
            success(false)
            
            return
        }
        
        let userDispatchGroup = DispatchGroup()
        let signUpFailed = DispatchGroup()
        
        userDispatchGroup.enter()
        signUpFailed.enter()
        
        usersDataRef.child(id).setValue(details) { (error, ref) in
            if error == nil {
                userDispatchGroup.leave()
            } else {
                signUpFailed.leave()
            }
        }
        
        userDispatchGroup.enter()
        signUpFailed.enter()
        
        usersLoginDataRef.child(loginEmail).setValue(loginDetails) { (error, ref) in
            if error == nil {
                userDispatchGroup.leave()
            } else {
                signUpFailed.leave()
            }
        }
        
        userDispatchGroup.notify(queue: .main) {
            success(true)
        }
        
        signUpFailed.notify(queue: .main) {
            success(false)
        }
    }
    
    func observeHomeIngredientAdded(forUserId id: String, completion: @escaping (HomeIngredient?) -> Void) {
        usersDataRef.child(id).child("homeIngredients").observe(.childAdded) { snapshot in
            self.parseHomeIngredientDetails(fromSnapshot: snapshot, withCompletionHandler: completion)
        }
    }
    
    func observeHomeIngredientChanged(forUserId id: String, completion: @escaping (HomeIngredient?) -> Void) {
        usersDataRef.child(id).child("homeIngredients").observe(.childChanged) { snapshot in
            self.parseHomeIngredientDetails(fromSnapshot: snapshot, withCompletionHandler: completion)
        }
    }
    
    func observeHomeIngredientRemoved(completion: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        usersDataRef.child(loggedInUserId).child("homeIngredients").observe(.childRemoved) { _ in
            completion()
        }
    }
    
    func observeRecipeRemoved(completion: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        usersDataRef.child(loggedInUserId).child("recipes").observe(.childRemoved) { _ in
            completion()
        }
    }
    
    private func parseHomeIngredientDetails(fromSnapshot snapshot: DataSnapshot, withCompletionHandler completion: @escaping (HomeIngredient?) -> Void) {
        guard let homeIngredientDetails = snapshot.value else {
            completion(nil)
            
            return
        }
        
        do {
            let homeIngredient = try FirebaseDecoder().decode(HomeIngredient.self, from: homeIngredientDetails)
            
            completion(homeIngredient)
        } catch let error {
            completion(nil)
            
            print(error)
        }
    }
    
    func observeRecipeAdded(forUserId id: String, completion: @escaping (Recipe?) -> Void) {
        usersDataRef.child(id).child("recipes").observe(.childAdded) { snapshot in
            self.parseRecipeDetails(fromSnapshot: snapshot, withCompletionHandler: completion)
        }
    }
    
    func observeRecipeChanged(forUserId id: String, completion: @escaping (Recipe?) -> Void) {
        usersDataRef.child(id).child("recipes").observe(.childChanged) { snapshot in
            self.parseRecipeDetails(fromSnapshot: snapshot, withCompletionHandler: completion)
        }
    }
    
    private func parseRecipeDetails(fromSnapshot snapshot: DataSnapshot, withCompletionHandler completion: @escaping (Recipe?) -> Void) {
        guard let recipeDetails = snapshot.value else {
            completion(nil)
            
            return
        }
        
        do {
            let recipe = try FirebaseDecoder().decode(Recipe.self, from: recipeDetails)
            
            completion(recipe)
        } catch let error {
            completion(nil)
            
            print(error)
        }
    }
    
    func updateRecipe(froUserId id: String,
                      andForRecipeId recipeId: String,
                      withDetails details: [String:Any],
                      andCompletionHandler completion: @escaping (Bool) -> Void) {
        usersDataRef.child(id).child("recipes").child(recipeId).updateChildValues(details) { (error, _) in
            completion(error == nil)
        }
    }
    
    func addHomeIngredient(withDetails details: [String:Any], success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id,
            let ingredientId = details["id"] as? String else
        {
            failure()
            
            return
        }
        
        usersDataRef.child(loggedInUserId).child("homeIngredients").child(ingredientId).setValue(details) { (error, _) in
            if error == nil {
                success()
            } else {
                failure()
            }
        }
    }
    
    func changeHomeIngrdient(withId id: String, andDetails details: [String:Any], success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else {
            failure()
            
            return
        }
        
        usersDataRef.child(loggedInUserId).child("homeIngredients").child(id).updateChildValues(details) { (error, _) in
            if error == nil {
                success()
            } else {
                failure()
            }
        }
    }
    
    func changeCookingDates(forRecipeId recipeId: String, withValue value: [String], success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else {
            failure()
            
            return
        }
        
        usersDataRef.child(loggedInUserId).child("recipes").child(recipeId).updateChildValues(["cookingDates": value]) { (error, _) in
            if error == nil {
                success()
            } else {
                failure()
            }
        }
    }
    
    func removeHomeIngredient(withId id: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else {
            failure()
            
            return
        }
        
        usersDataRef.child(loggedInUserId).child("homeIngredients").child(id).removeValue { (error, _) in
            if error == nil {
                success()
            } else {
                failure()
            }
        }
    }
    
    func removeRecipe(withId id: String, success: @escaping () -> Void, failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else {
            failure()
            
            return
        }
        
        usersDataRef.child(loggedInUserId).child("recipes").child(id).removeValue { (error, _) in
            if error == nil {
                success()
            } else {
                failure()
            }
        }
    }
    
    func getCustomIngredients() {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        usersDataRef.child(loggedInUserId).child("customIngredients").observeSingleEvent(of: .value) { snapshot in
            guard let customIngredients = snapshot.value else { return }
            
            do {
                let ingredients = try FirebaseDecoder().decode(CustomIngredients.self, from: customIngredients)
                
                IngredientsManager.shared.customIngredients = ingredients
            } catch let error {
                print(error)
            }
        }
    }
    
    func postCustomIngredient(inCategory category: String, withName name: String) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        usersDataRef.child(loggedInUserId).child("customIngredients").child(category).setValue([name])
    }
}
