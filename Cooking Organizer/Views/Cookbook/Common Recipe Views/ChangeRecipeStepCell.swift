//
//  ChangeRecipeStepCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol ChangeRecipeStepCellDelegate: AnyObject {
    func stepChanged(withValue string: String?, atIndex index: Int)
    func stepDetailsFieldSelected(withText text: String?, atIndex index: Int)
}

class ChangeRecipeStepCell: UITableViewCell {
    @IBOutlet weak var stepNrLabel: UILabel! {
        didSet {
            self.stepNrLabel.font = UIFont(name: "Proxima Nova Alt Regular", size: 17.0)
        }
    }
    @IBOutlet weak var stepDetailsTextField: UITextField! {
        didSet {
            self.stepDetailsTextField.borderStyle = .none
            self.stepDetailsTextField.layer.cornerRadius = 14.0
            self.stepDetailsTextField.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
            self.stepDetailsTextField.font = UIFont(name: "Proxima Nova Alt Regular", size: 16.0)
        }
    }
    
    var index: Int = -1
    
    weak var delegate: ChangeRecipeStepCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stepDetailsTextField.delegate = self
    }
}

// MARK: - TextField Delegate
extension ChangeRecipeStepCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        delegate?.stepChanged(withValue: textField.text, atIndex: index)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.endEditing(true)
        
        delegate?.stepDetailsFieldSelected(withText: textField.text, atIndex: index)
    }
}
