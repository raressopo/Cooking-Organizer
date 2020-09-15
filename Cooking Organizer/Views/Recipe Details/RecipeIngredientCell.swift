//
//  RecipeIngredientCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 14/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeIngredientCell: UITableViewCell {
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var quantityUnitLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkbox.checkmarkStyle = .tick
        checkbox.borderStyle = .circle
        checkbox.checkedBorderColor = .systemGray5
        checkbox.checkmarkColor = .darkGray
    }
}
