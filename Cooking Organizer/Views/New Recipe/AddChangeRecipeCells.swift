//
//  AddChangeRecipeCells.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/04/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

protocol AddChangeRecipeTextFieldCellDelegate: AnyObject {
    func textFieldDidChanged(forSection section: NewRecipeSection, andText text: String)
}

class AddChangeRecipeTextFieldCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    weak var delegate: AddChangeRecipeTextFieldCellDelegate?
    var section: NewRecipeSection?
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let section = section, let text = textField.text {
            self.delegate?.textFieldDidChanged(forSection: section, andText: text)
        }
    }
}

class AddChangeRecipeTextViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
    
}

class AddChangeRecipeImageCell: UITableViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var removeImageButton: UIButton!
    
}
