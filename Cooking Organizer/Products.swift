//
//  Products.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

struct Products: Codable {
    let diaryProducts: [String]
    let vegetablesProducts: [String]
    
    enum CodingKeys: String, CodingKey {
        case diaryProducts = "Diary"
        case vegetablesProducts = "Vegetables"
    }
}
