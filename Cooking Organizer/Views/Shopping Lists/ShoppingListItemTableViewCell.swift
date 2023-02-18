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
    @IBOutlet weak var itemNameLabel: UILabel! {
        didSet {
            itemNameLabel.font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0)
        }
    }
    @IBOutlet weak var itemQuantityAndUnitLabel: UILabel! {
        didSet {
            itemQuantityAndUnitLabel.font = UIFont(name: "Proxima Nova Alt Light", size: 15.0)
        }
    }
    @IBOutlet weak var boughtView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkbox.checkmarkStyle = .tick
        checkbox.borderStyle = .circle
        checkbox.checkedBorderColor = UIColor.buttonTitleColor()
        checkbox.uncheckedBorderColor = UIColor.buttonTitleColor()
        checkbox.checkmarkColor = UIColor.buttonTitleColor()
    }
}
