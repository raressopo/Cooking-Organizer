//
//  AddShoppingListItemView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import SearchTextField

class AddShoppingListItemView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var itemNameSearchTextField: SearchTextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedUnit: String?
    var selectedShoppingList: ShoppingList?
    var selectedShoppingListItem: ShoppingListItem?
    
    var changeMode = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    init(changeMode: Bool = false, shoppingListItem: ShoppingListItem? = nil, shoppingList: ShoppingList?, frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
        
        selectedShoppingList = shoppingList
        
        if changeMode {
            itemNameSearchTextField.text = shoppingListItem?.name
            itemNameSearchTextField.isEnabled = false
            
            quantityTextField.text = "\(shoppingListItem?.quantity ?? 0)"
            unitButton.setTitle(shoppingListItem?.unit, for: .normal)
            
            selectedUnit = shoppingListItem?.unit
            selectedShoppingListItem = shoppingListItem
            
            self.changeMode = changeMode
        }
        
        saveButton.setTitle(changeMode ? "Change" : "Save", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AddShoppingListItemView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        itemNameSearchTextField.filterStrings(IngredientsManager.shared.allProducts)
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        removeFromSuperview()
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
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let shoppingListName = selectedShoppingList?.name else { return }
        
        guard let quantity = quantityTextField.text, let quantityAsDouble = NumberFormatter().number(from: quantity)?.doubleValue else {
            if let parentVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC, title: "Invalid Quantity", message: "Please make sure that you entered a number in Quantity field (eg. 1, 20.2, 11.0 etc.)")
            }
            
            return
        }
        
        guard let itemName = itemNameSearchTextField.text, !itemName.isEmpty else {
            if let parentVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC, title: "Invalid Name", message: "Please make sure that you entered a name in Item Name field")
            }
            
            return
        }
        
        guard let unit = selectedUnit else {
            if let parentVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC, title: "Invalid Unit", message: "Please make sure that you have selected an unit")
            }
            
            return
        }
        
        if changeMode {
            var changedItemValues = [String: Any]()
            
            if let itemUnit = selectedShoppingListItem?.unit, itemUnit != unit {
                changedItemValues["unit"] = unit
            }
            
            if let itemQuantity = selectedShoppingListItem?.quantity, itemQuantity != quantityAsDouble {
                changedItemValues["quantity"] = quantityAsDouble
            }
            
            if !changedItemValues.isEmpty, let listName = selectedShoppingList?.name {
                UserDataManager.shared.changeShoppingListItem(fromList: listName, withItemName: itemName, andValues: changedItemValues) {
                    self.removeFromSuperview()
                } failure: {
                    if let parentVC = self.window?.rootViewController?.presentedViewController {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC, title: "Change Failed", message: "Something went wrong changing the item")
                    }
                    
                    self.removeFromSuperview()
                }
            }
        } else {
            UserDataManager.shared.addShoppingListItem(onList: shoppingListName, withName: itemName, andValues: ["name": itemName, "quantity": quantityAsDouble, "unit": unit, "bought": false]) {
                self.removeFromSuperview()
            } failure: {
                if let parentVC = self.window?.rootViewController?.presentedViewController {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC, title: "Creation Failed", message: "Something went wrong adding item to list")
                }
                
                self.removeFromSuperview()
            }
        }
    }
}

extension AddShoppingListItemView: UnitPickerViewDelegate {
    func didSelectUnit(unit: String) {
        selectedUnit = unit
        
        unitButton.setTitle(unit, for: .normal)
    }
}
