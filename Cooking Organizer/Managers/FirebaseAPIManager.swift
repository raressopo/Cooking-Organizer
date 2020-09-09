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
}
