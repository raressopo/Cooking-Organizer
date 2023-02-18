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
    
    @IBOutlet weak var textField: UITextField! {
        didSet {
            let attributes = [
                NSAttributedString.Key.font : UIFont(name: "Proxima Nova Alt Regular", size: 14.0)!
            ]

            self.textField.attributedPlaceholder = NSAttributedString(string: "Please enter recipe name", attributes:attributes)
            self.textField.backgroundColor = UIColor.hexStringToUIColor(hex: "#88AA8D").withAlphaComponent(0.7)
        }
    }
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = 16.0
            self.containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    weak var delegate: AddChangeRecipeTextFieldCellDelegate?
    
    var section: NewRecipeSection?
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let section = section, let text = textField.text {
            self.delegate?.textFieldDidChanged(forSection: section, andText: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
    }
}

class AddChangeRecipeTextViewCell: UITableViewCell {
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            self.textView.font = UIFont(name: "Proxima Nova Alt Thin", size: 14.0)
        }
    }
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = 16.0
            self.containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
}

class AddChangeRecipeImageCell: UITableViewCell {
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var removeImageButton: UIButton! {
        didSet {
            self.removeImageButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#D71309"), for: .normal)
            self.removeImageButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 17.0)
        }
    }
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.clipsToBounds = true
            self.containerView.layer.cornerRadius = 16.0
            self.containerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.recipeImageView.isHidden = true
        self.removeImageButton.isHidden = true
    }
    
}
