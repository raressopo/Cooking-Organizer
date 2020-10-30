//
//  ShoppingListItemTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 29/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class ShoppingListItemTableViewCell: UITableViewCell {
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemQuantityAndUnitLabel: UILabel!
    @IBOutlet weak var boughtView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkbox.checkmarkStyle = .tick
        checkbox.borderStyle = .circle
        checkbox.checkedBorderColor = .systemGray5
        checkbox.checkedBorderColor = .darkGray
    }
}
