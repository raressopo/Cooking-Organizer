//
//  ShoppingListTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 04/02/2023.
//  Copyright © 2023 Rares Soponar. All rights reserved.
//

import Foundation

class ShoppingListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var listName: UILabel! {
        didSet {
            listName.font = UIFont(name: "Proxima Nova Alt Bold", size: 19.0)
            listName.numberOfLines = 3
            listName.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var nrOfIngredientsToBuy: UILabel! {
        didSet {
            nrOfIngredientsToBuy.font = UIFont(name: "Proxima Nova Alt Light", size: 16.0)
        }
    }
    
}
