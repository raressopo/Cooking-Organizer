//
//  ChangeRecipeIngredientCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 14/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import SearchTextField

protocol ChangeRecipeIngredientCellDelegate: AnyObject {
    func ingredientTextFieldSelected(withIndex index: Int)
}

class ChangeRecipeIngredientCell: UITableViewCell {
    @IBOutlet weak var ingredientNameTextField: SearchTextField! {
        didSet {
            self.ingredientNameTextField.borderStyle = .none
            self.ingredientNameTextField.layer.cornerRadius = 10.0
            self.ingredientNameTextField.textAlignment = .center
            self.ingredientNameTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#88AA8D").withAlphaComponent(0.7)
            self.ingredientNameTextField.font = UIFont(name: "Proxima Nova Alt Regular", size: 15.0)
        }
    }
    @IBOutlet weak var quantityTextField: UITextField! {
        didSet {
            self.quantityTextField.borderStyle = .none
            self.quantityTextField.layer.cornerRadius = 10.0
            self.quantityTextField.textAlignment = .center
            self.quantityTextField.backgroundColor = UIColor.hexStringToUIColor(hex: "#88AA8D").withAlphaComponent(0.7)
            self.quantityTextField.font = UIFont(name: "Proxima Nova Alt Regular", size: 14.0)
        }
    }
    @IBOutlet weak var unitButton: UIButton! {
        didSet {
            self.unitButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 14.0)
            self.unitButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#C17A03"), for: .normal)
        }
    }
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.layer.cornerRadius = 14.0
        }
    }
    
    weak var delegate: ChangeRecipeIngredientCellDelegate?
    
    var ingredient: NewRecipeIngredient?
    var index: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ingredientNameTextField.delegate = self
        quantityTextField.delegate = self
        
        ingredientNameTextField.filterStrings(IngredientsManager.shared.allProducts)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.ingredientTextFieldSelected(withIndex: index)
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
