//
//  HomeIngredientDetailsView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 05/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase
import SearchTextField

class HomeIngredientDetailsView: UIView {
    @IBOutlet weak var dismissIngredientDetailsButton: UIButton!
    @IBOutlet weak var ingredientDetailsView: UIView!
    @IBOutlet weak var ingredientNameTextField: SearchTextField!
    @IBOutlet weak var expirationDateButton: UIButton!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    var selectedCategory: IngredientCategories?
    var selectedUnit: String?
    var selectedExpirationDate: Date?
    
    var allIngredientCategoriesAsString: String?
    
    @IBOutlet var contentView: UIView!
    
    var homeIngredient: HomeIngredient?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    // MARK: - Private Helpers
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HomeIngredientDetailsView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        categoriesButton.titleLabel?.numberOfLines = 3
        categoriesButton.setNeedsLayout()
        
        ingredientNameTextField.filterStrings(IngredientsManager.shared.allProducts)
        ingredientNameTextField.delegate = self
    }
    
    private func validateNewIngredientsDetails(completion: @escaping ([String: Any]) -> Void) {
        guard let ingredientName = ingredientNameTextField.text,
              !ingredientName.isEmpty else {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Ingredient Name",
                                                                  message: "Please choose a valid name and don't let the field empty")
            }
            
            return
        }
        
        guard let ingredientQuantity = quantityTextField.text,
              !ingredientQuantity.isEmpty,
              let ingredientQuantityAsNumber = NumberFormatter().number(from: ingredientQuantity),
              let quantity = ingredientQuantityAsNumber as? Double else {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Quantity",
                                                                  message: "Please choose a valid quantity and don't let the field empty")
            }
            
            return
        }
        
        let categoryAsString = selectedCategory?.string ?? ""
        
        if categoryAsString.isEmpty {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Categories",
                                                                  message: "Please select at least one category")
            }
            
            return
        }
        
        var expirationDateString = ""
        
        if let expirationDate = selectedExpirationDate {
            expirationDateString = UtilsManager.shared.dateFormatter.string(from: expirationDate)
        }
        
        if expirationDateString.isEmpty {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Expiration Date",
                                                                  message: "Please select a valid expiration date")
            }
            
            return
        }
        
        guard let selectedUnit = selectedUnit, !selectedUnit.isEmpty else {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Unit",
                                                                  message: "Please select an unit")
            }
            
            return
        }
        
        if !IngredientsManager.shared.allProducts.contains(ingredientName) {
            FirebaseAPIManager.sharedInstance.postCustomIngredient(inCategory: selectedCategory!.dbKeyString, withName: ingredientName)
            
            IngredientsManager.shared.addNewCustomIngredients(customIngredient: ingredientName, inCategory: selectedCategory!)
        }
        
        let uuid = UUID().uuidString
        
        completion(["name": ingredientName,
                    "expirationDate": expirationDateString,
                    "quantity": quantity,
                    "unit": selectedUnit,
                    "category": categoryAsString,
                    "id": uuid])
    }
    
    private func validateChangedIngredient(completion: @escaping ([String: Any], String) -> Void) {
        guard let ingredient = homeIngredient else {
            if let presentedViewController = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                  title: "Ingredient missing",
                                                                  message: "Selected ingredient is not valid or it doesn't exist anymore.")
            }
            
            return
        }
        
        var ingredientChanged = false
        var changedDataDictionary = [String: Any]()
        
        var changedName = ""
        if let name = ingredientNameTextField.text, ingredient.name != name {
            changedDataDictionary["name"] = name
            changedName = name
            
            ingredientChanged = true
        }
        
        if let expirationDate = selectedExpirationDate, ingredient.expirationDate != UtilsManager.shared.dateFormatter.string(from: expirationDate) {
            changedDataDictionary["expirationDate"] = UtilsManager.shared.dateFormatter.string(from: expirationDate)
            
            ingredientChanged = true
        }
        
        if let quantity = quantityTextField.text, let quantityAsDouble = NumberFormatter().number(from: quantity)?.doubleValue, ingredient.quantity != quantityAsDouble {
            changedDataDictionary["quantity"] = quantityAsDouble
            
            ingredientChanged = true
        }
        
        if let unit = selectedUnit, ingredient.unit != unit {
            changedDataDictionary["unit"] = unit
            
            ingredientChanged = true
        }
        
        if let categoryString = selectedCategory?.string, ingredient.category != categoryString {
            changedDataDictionary["category"] = categoryString
            
            ingredientChanged = true
        }
        
        if ingredientChanged {
            if !changedName.isEmpty, !IngredientsManager.shared.allProducts.contains(changedName), let category = selectedCategory {
                FirebaseAPIManager.sharedInstance.postCustomIngredient(inCategory: category.dbKeyString, withName: changedName)
                
                IngredientsManager.shared.addNewCustomIngredients(customIngredient: changedName, inCategory: category)
            }
            
            completion(changedDataDictionary, ingredient.id)
        } else {
            if let presentedViewController = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                  title: "Update Failed",
                                                                  message: "You didn't change any of presented details for selected ingredient")
            }
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func createChangedPressed(_ sender: Any) {
        if createButton.titleLabel?.text == "Create" {
            validateNewIngredientsDetails { newIngredientDetails in
                UserDataManager.shared.addNewHomeIngredient(withDetails: newIngredientDetails, success: {
                    self.removeFromSuperview()
                }, failure: {
                    if let presentedViewController = self.window?.rootViewController?.presentedViewController {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                          title: "Ingredient Creation Failed",
                                                                          message: "Something went wrong creating new ingredient. Please try again later!")
                    }
                })
            }
        } else {
            validateChangedIngredient { (changedIngredientDetails, ingredientId) in
                UserDataManager.shared.changeHomeIngredient(withId: ingredientId, andDetails: changedIngredientDetails, success: {
                    self.removeFromSuperview()
                }, failure: {
                    if let presentedViewController = self.window?.rootViewController?.presentedViewController {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                          title: "Update Failed",
                                                                          message: "Something went wrong changing the selected ingredient. Please try again later!")
                    }
                })
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func dismissIngredientDetailsPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    // MARK: - Categories
    
    // MARK: - Categories - IBActions
    
    @IBAction func categoriesPressed(_ sender: Any) {
        let categoriesView = HomeIngredientsCategoriesView()
        
        categoriesView.delegate = self
        categoriesView.selectedCategoryName = selectedCategory?.string
        
        addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)])
    }
    
    // MARK: - Expiration, Bought or Opened date
    
    // MARK: - Expiration, Bought or Opened date - IBActions
    
    @IBAction func expirationDatePressed(_ sender: Any) {
        displayDatePickerView()
    }
    
    private func displayDatePickerView() {
        let datePickerView = LastCookDatePickerView()
        
        datePickerView.neverCookedButton.removeFromSuperview()
        datePickerView.delegate = self
        
        contentView.addSubview(datePickerView)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([datePickerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
                                     datePickerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
                                     datePickerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
                                     datePickerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)])
    }
    
    // MARK: - Unit
    
    // MARK: - Unit - IBActions
    
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
    
    // MARK: - Unit - Private Helpers
    
    private func configureUnitButton() {
        if let unit = selectedUnit {
            unitButton.setTitle(unit, for: .normal)
        } else {
            unitButton.setTitle("Unit", for: .normal)
        }
    }
    
    // MARK: - Public Helpers
    
    func populateFields(withIngredient ingredient: HomeIngredient) {
        homeIngredient = ingredient
        
        ingredientNameTextField.text = ingredient.name
        
        if let expDate = ingredient.expirationDate {
            expirationDateButton.setTitle(expDate, for: .normal)
            selectedExpirationDate = UtilsManager.shared.dateFormatter.date(from: expDate)
        }
        
        quantityTextField.text = "\(ingredient.quantity ?? 0.0)"
        
        if let unit = ingredient.unit {
            selectedUnit = unit
            unitButton.setTitle(unit, for: .normal)
        }
        
        selectedCategory = IngredientCategories.allCases.first(where: {$0.string == ingredient.category ?? ""})
        
        categoriesButton.setTitle(selectedCategory?.string, for: .normal)
    }
}

extension HomeIngredientDetailsView: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField is SearchTextField,
           let ingredientName = textField.text,
           let category = IngredientsManager.shared.ingredientCategory(forIngredient: ingredientName) {
            selectedCategory = category
            
            categoriesButton.setTitle(category.string, for: .normal)
        }
    }
}

extension HomeIngredientDetailsView: CategoriesViewDelegate {
    func didSelectIngredientCategory(withCategory category: IngredientCategories) {
        selectedCategory = category
        
        categoriesButton.setTitle(category.string, for: .normal)
    }
}

extension HomeIngredientDetailsView: LastCookDatePickerViewDelegate {
    func didSelectLastCookDate(date: Date?) {
        selectedExpirationDate = date
        
        if let selectedDate = date {
            expirationDateButton.setTitle(UtilsManager.shared.dateFormatter.string(from: selectedDate), for: .normal)
        }
    }
}

extension HomeIngredientDetailsView: UnitPickerViewDelegate {
    func didSelectUnit(unit: String) {
        selectedUnit = unit
        
        unitButton.setTitle(unit, for: .normal)
    }
}
