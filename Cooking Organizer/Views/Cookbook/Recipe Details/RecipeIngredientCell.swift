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
    @IBOutlet weak var quantityUnitLabel: UILabel! {
        didSet {
            self.quantityUnitLabel.font = UIFont(name: "Proxima Nova Alt Regular", size: 15.0)
        }
    }
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            self.nameLabel.font = UIFont(name: "Proxima Nova Alt Bold", size: 16.0)
        }
    }
    @IBOutlet weak var checkedStateView: UIView!
    
    @IBOutlet weak var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.containerView.layer.cornerRadius = 14.0
        checkbox.checkmarkStyle = .circle
        checkbox.borderStyle = .circle
        checkbox.borderLineWidth = 3.0
        checkbox.uncheckedBorderColor = UIColor.buttonTitleColor()
        checkbox.checkedBorderColor = UIColor.buttonTitleColor()
        checkbox.checkmarkColor = UIColor.buttonTitleColor()
    }
    
    func changeCheckedState(to checked: Bool) {
        self.checkbox.isChecked = checked
        
        self.checkedStateView.isHidden = !checked
        self.checkedStateView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
    }
}
