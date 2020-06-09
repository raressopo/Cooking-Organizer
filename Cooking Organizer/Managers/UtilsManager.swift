//
//  UtilsManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class UtilsManager: NSObject {
    static let shared = UtilsManager()
    
    let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
    }
}
