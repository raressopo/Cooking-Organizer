//
//  AddChangeRecipeCells.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/04/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

class AddChangeRecipeTextFieldCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
}

class AddChangeRecipeTextViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView!
}

class AddChangeRecipeImageCell: UITableViewCell {
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var removeImageButton: UIButton!
    
}
