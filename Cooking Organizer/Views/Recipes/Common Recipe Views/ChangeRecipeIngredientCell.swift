//
//  ChangeRecipeIngredientCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 14/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class ChangeRecipeIngredientCell: UITableViewCell {
    @IBOutlet weak var ingredientNameTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    
    var ingredient: NewRecipeIngredient?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ingredientNameTextField.delegate = self
        quantityTextField.delegate = self
    }
}

// MARK: - TextField Delegate

extension ChangeRecipeIngredientCell: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField.placeholder == "Ingredient" {
            ingredient?.name = ingredientNameTextField.text
        } else {
            ingredient?.quantity = quantityTextField.text
        }
    }
}

// MARK: - UnitPickerView Delegate

extension ChangeRecipeIngredientCell: UnitPickerViewDelegate {
    func didSelectUnit(unit: String) {
        ingredient?.unit = unit
        
        unitButton.setTitle(unit, for: .normal)
    }
    
    @IBAction func unitPressed(_ sender: Any) {
        let unitPickerView = UnitPickerView()
        
        unitPickerView.delegate = self
        
        if let parentVCView = window?.rootViewController?.presentedViewController?.view {
            parentVCView.addSubview(unitPickerView)
            
            unitPickerView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([unitPickerView.topAnchor.constraint(equalTo: parentVCView.topAnchor, constant: 0.0),
                                         unitPickerView.bottomAnchor.constraint(equalTo: parentVCView.bottomAnchor, constant: 0.0),
                                         unitPickerView.trailingAnchor.constraint(equalTo: parentVCView.trailingAnchor, constant: 0.0),
                                         unitPickerView.leadingAnchor.constraint(equalTo: parentVCView.leadingAnchor, constant: 0.0)])
        }
    }
}
