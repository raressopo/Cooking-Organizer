//
//  UsersManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 20/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol UsersManagerDelegate: class {
    func usersDidFetched()
}

extension UsersManagerDelegate {
    func usersDidFetched() {}
}

class UsersManager: NSObject {
    static let shared = UsersManager()
    weak var delegate: UsersManagerDelegate?
    
    var allUsers = [User]()
    var isInitialFetchFinished = false
    var currentLoggedInUser: User?
    
    override init() {
        super.init()
        
        observeUserAdded()
        observeUserRemoved()
        observeUserChanged()
    }
    
    func addUserToDB(with email: String, password: String, completion: @escaping (Error?, DatabaseReference) -> Void) {
        let usersDBReference = Database.database().reference().child("users")
        
        let uuid = UUID().uuidString
        
        usersDBReference.child(uuid).setValue(["email": email, "password": password]) { (error, ref) in
            if error == nil {
                Database.database().reference().child("usersData").child(uuid).setValue(["signUpDate": UtilsManager.shared.dateFormatter.string(from: Date())], withCompletionBlock: completion)
            }
        }
    }
    
    func fetchUsersFromDB() {
        Database.database().reference().observeSingleEvent(of: .value) { (snapshot) in
            guard let database = snapshot.value as? [String:Any] else { return }
            
            if let users = database["users"] as? [String: Any] {
                for dbUser in users.keys {
                    let user = User()
                    
                    user.id = dbUser
                    
                    guard let userDetails = users[dbUser] as? [String:Any] else { return }
                    
                    if let email = userDetails["email"] as? String {
                        user.email = email
                    }
                    
                    if let password = userDetails["password"] as? String {
                        user.password = password
                    }
                    
                    self.allUsers.append(user)
                    
                    if users.count == self.allUsers.count {
                        self.delegate?.usersDidFetched()
                        
                        self.isInitialFetchFinished = true
                    }
                }
            }
        }
    }
    
    func observeUserAdded() {
        Database.database().reference().child("users").observe(.childAdded) { (snapshot) in
            if self.isInitialFetchFinished, !self.allUsers.contains(where: { (user) -> Bool in
                if let userId = user.id {
                    return userId == snapshot.key
                } else {
                    return false
                }
            }) {
                let user = User()
                
                user.id = snapshot.key
                
                guard let userDetails = snapshot.value as? [String:Any] else { return }
                
                if let email = userDetails["email"] as? String {
                    user.email = email
                }
                
                if let password = userDetails["password"] as? String {
                    user.password = password
                }
                
                self.allUsers.append(user)
            }
        }
    }
    
    func observeUserRemoved() {
        Database.database().reference().child("users").observe(.childRemoved) { (snapshot) in
            if let removedUser = self.allUsers.first(where: { (user) -> Bool in
                if let userId = user.id {
                    return snapshot.key == userId
                } else {
                    return false
                }
            }) {
                if let removedUserIndex = self.allUsers.firstIndex(of: removedUser) {
                    self.allUsers.remove(at: removedUserIndex)
                }
            }
        }
    }
    
    func observeUserChanged() {
        Database.database().reference().child("users").observe(.childChanged) { (snapshot) in
            if self.isInitialFetchFinished {
                let changedUser = self.allUsers.first { (user) -> Bool in
                    if let userId = user.id {
                        return snapshot.key == userId
                    } else {
                        return false
                    }
                }
                
                guard let user = changedUser,
                    let userDetails = snapshot.value as? [String:Any] else { return }
                
                if let email = userDetails["email"] as? String {
                    user.email = email
                }
                
                if let password = userDetails["password"] as? String {
                    user.password = password
                }
            }
        }
    }
}
