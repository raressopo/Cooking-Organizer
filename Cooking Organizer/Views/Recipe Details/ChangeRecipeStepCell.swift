//
//  ChangeRecipeStepCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol ChangeRecipeStepCellDelegate: class {
    func stepChanged(withValue string: String?, atIndex index: Int)
}

class ChangeRecipeStepCell: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var stepNrLabel: UILabel!
    @IBOutlet weak var stepDetailsTextField: UITextField!
    
    var index: Int = -1
    
    weak var delegate: ChangeRecipeStepCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stepDetailsTextField.delegate = self
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.stepChanged(withValue: textField.text, atIndex: index)
    }
}
