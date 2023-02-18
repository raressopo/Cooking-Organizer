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
    
    @IBOutlet weak var stepDetailLabel: UILabel!
    @IBOutlet weak var checkedStateView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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

extension UITextView {
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
}
