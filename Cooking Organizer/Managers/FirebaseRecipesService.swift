//
//  FirebaseRecipesService.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/10/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class FirebaseRecipesService {
    
    static let shared = FirebaseRecipesService()
    
    private let usersDataRef = Database.database().reference().child("usersData")
    private let usersLoginDataRef = Database.database().reference().child("usersLoginData")
    
    func addRecipe(withRecipeDictionary dictionary: [String: Any],
                   andID id: String,
                   success: @escaping () -> Void,
                   failure: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        Database.database().reference().child("usersData")
            .child(loggedInUserId)
            .child("recipes")
            .child(id)
            .setValue(dictionary) { (error, _) in
                if error == nil {
                    success()
                } else {
                    failure()
                }
            }
    }
    
    func updateRecipe(froUserId id: String,
                      andForRecipeId recipeId: String,
                      withDetails details: [String: Any],
                      andCompletionHandler completion: @escaping (Bool) -> Void) {
        usersDataRef.child(id).child("recipes").child(recipeId).updateChildValues(details) { (error, _) in
            completion(error == nil)
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
    
    // MARK: - Observers
    
    func observeRecipeRemoved(completion: @escaping () -> Void) {
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }
        
        usersDataRef.child(loggedInUserId).child("recipes").observe(.childRemoved) { _ in
            completion()
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
    
    // MARK: - Private helpers
    
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
    
}
