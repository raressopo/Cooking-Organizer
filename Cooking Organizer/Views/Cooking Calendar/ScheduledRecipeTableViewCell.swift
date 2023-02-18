//
//  ScheduledRecipeTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 05/02/2023.
//  Copyright © 2023 Rares Soponar. All rights reserved.
//

import Foundation

class ScheduledRecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeName: UILabel! {
        didSet {
            recipeName.font = UIFont(name: "Proxima Nova Alt Regular", size: 16.0)
        }
    }
    
}
