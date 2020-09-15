//
//  RecipeStepCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeStepCell: UITableViewCell {
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var stepNrLabel: UILabel!
    @IBOutlet weak var stepDetailsTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkbox.checkmarkStyle = .tick
        checkbox.borderStyle = .circle
        checkbox.checkedBorderColor = .systemGray5
        checkbox.checkmarkColor = .darkGray
    }
}
