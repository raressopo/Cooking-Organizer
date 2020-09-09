//
//  UsersManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

class UsersManager: NSObject {
    static let shared = UsersManager()
    
    var currentLoggedInUser: User?
    
    func createUser(withEmail email: String, password: String, andCompletionHandler completion: @escaping (Bool) -> Void) {
        let id = UUID().uuidString
        
        let details = ["email": email,
                       "signUpDate": UtilsManager.shared.dateFormatter.string(from: Date())]
        
        let loginDetails = ["email": email,
                            "password": password,
                            "id": id]
        
        FirebaseAPIManager.sharedInstance.createUser(withDetails: details,
                                                     andLoginDetails: loginDetails,
                                                     success: completion)
    }
    
    func validateUserAndLogIn(withEmail email: String, password: String, andCompletionHandler completion: @escaping (_ id: String?) -> Void) {
        FirebaseAPIManager.sharedInstance.validateUser(withEmail: email) { loginData in
            guard let loginData = loginData, loginData.password == password else {
                completion(nil)
                return
            }
            
            FirebaseAPIManager.sharedInstance.getUser(withId: loginData.id, loginData: loginData) { user in
                if let user = user {
                    self.currentLoggedInUser = user
                    
                    completion(loginData.id)
                } else {
                    completion(nil)
                }
            }
        }
    }
}
