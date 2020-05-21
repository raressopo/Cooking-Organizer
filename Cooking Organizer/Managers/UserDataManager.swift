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
}

extension UserDataManagerDelegate {
    func userDataDidFetch() {}
}

class UserDataManager: NSObject {
    static let shared = UserDataManager()
    weak var delegate: UsersManagerDelegate?
    
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
        }
    }
}
