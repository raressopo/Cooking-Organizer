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
    
    @IBOutlet weak var dismissCategoriesButton: UIButton!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var categoriesTableView: UITableView!
    
    var selectedCategories = [IngredientCategories]()
    var copyOfSelectedCategories = [IngredientCategories]()
    
    @IBOutlet weak var dismissDatePickerButton: UIButton!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var expirationDatePicker: UIDatePicker!
    
    @IBOutlet weak var dismissUnitViewButton: UIButton!
    @IBOutlet weak var unitView: UIView!
    @IBOutlet weak var unitsTableView: UITableView!
    
    var selectedUnit: String?
    var copyOfSelectedUnit: String?
    
    let volumeUnits = ["tsp", "tbsp", "cup", "cups", "ml", "L"]
    let massAndWeightUnits = ["lb", "oz", "mg", "g", "kg"]
    
    var expirationdate: Date?
    
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
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
        
        unitsTableView.delegate = self
        unitsTableView.dataSource = self
        
        categoriesButton.titleLabel?.numberOfLines = 3
        categoriesButton.setNeedsLayout()
        
        ingredientNameTextField.filterStrings(ProductsManager.shared.allProducts)
    }
    
    private func validateNewIngredientsDetails(completion: @escaping ([String:Any]) -> Void) {
        guard let ingredientName = ingredientNameTextField.text,
            !ingredientName.isEmpty else
        {
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
            let quantity = ingredientQuantityAsNumber as? Double else
        {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Quantity",
                                                                  message: "Please choose a valid quantity and don't let the field empty")
            }
            
            return
        }
        
        var categoriesAsString = ""
        
        if selectedCategories.count > 0 {
            if selectedCategories.count == 1 {
                categoriesAsString = "\(selectedCategories.first!.string)"
            } else {
                for category in selectedCategories {
                    if selectedCategories.last! == category {
                        categoriesAsString = categoriesAsString + "\(category.string)"
                    } else {
                        categoriesAsString = categoriesAsString + "\(category.string), "
                    }
                }
            }
        }
        
        if categoriesAsString.isEmpty {
            if let rootVC = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: rootVC,
                                                                  title: "Invalid Categories",
                                                                  message: "Please select at least one category")
            }
            
            return
        }
        
        var expirationDateString = ""
        
        if let expirationDate = expirationdate {
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
        
        let uuid = UUID().uuidString
        
        completion(["name": ingredientName,
                    "expirationDate": expirationDateString,
                    "quantity": quantity,
                    "unit": selectedUnit,
                    "categories": categoriesAsString,
                    "id": uuid])
    }
    
    private func validateChangedIngredient(completion: @escaping ([String:Any], String) -> Void) {
        guard let ingredient = homeIngredient else {
            if let presentedViewController = window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                  title: "Ingredient missing",
                                                                  message: "Selected ingredient is not valid or it doesn't exist anymore.")
            }
            
            return
        }
        
        var ingredientChanged = false
        var changedDataDictionary = [String:Any]()
        
        if let name = ingredientNameTextField.text, ingredient.name != name {
            changedDataDictionary["name"] = name
            
            ingredientChanged = true
        }
        
        if let expirationDate = expirationdate, ingredient.expirationDate != UtilsManager.shared.dateFormatter.string(from: expirationDate) {
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
        
        if let categoriesAsString = allIngredientCategoriesAsString, ingredient.categories != categoriesAsString {
            changedDataDictionary["categories"] = categoriesAsString
            
            ingredientChanged = true
        }
        
        if ingredientChanged {
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
                }) {
                    if let presentedViewController = self.window?.rootViewController?.presentedViewController {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                          title: "Ingredient Creation Failed",
                                                                          message: "Something went wrong creating new ingredient. Please try again later!")
                    }
                }
            }
        } else {
            validateChangedIngredient { (changedIngredientDetails, ingredientId) in
                UserDataManager.shared.changeHomeIngredient(withId: ingredientId, andDetails: changedIngredientDetails, success: {
                    self.removeFromSuperview()
                }) {
                    if let presentedViewController = self.window?.rootViewController?.presentedViewController {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: presentedViewController,
                                                                          title: "Update Failed",
                                                                          message: "Something went wrong changing the selected ingredient. Please try again later!")
                    }
                }
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
        hideCategoriesView(hide: false)
        
        copyOfSelectedCategories = selectedCategories
        
        categoriesTableView.reloadData()
    }
    
    @IBAction func cancelCategoriesPressed(_ sender: Any) {
        hideCategoriesView(hide: true)
    }
    
    @IBAction func saveCategoriesPressed(_ sender: Any) {
        hideCategoriesView(hide: true)
        
        selectedCategories = copyOfSelectedCategories
        
        configureCategoriesButton()
    }
    
    @IBAction func dismissCategoriesViewPressed(_ sender: Any) {
        hideCategoriesView(hide: true)
    }
    
    // MARK: - Categories - Private Helpers
    
    private func hideCategoriesView(hide: Bool) {
        dismissCategoriesButton.isHidden = hide
        categoriesView.isHidden = hide
    }
    
    private func configureCategoriesButton() {
        var categoriesButtonTitle = ""
        
        if selectedCategories.count == 0 {
            categoriesButtonTitle = "Categories"
        } else if selectedCategories.count == 1 {
            categoriesButtonTitle = "\(selectedCategories.first!.string)"
        } else {
            for category in selectedCategories {
                if selectedCategories.last! == category {
                    categoriesButtonTitle = categoriesButtonTitle + "\(category.string)"
                } else {
                    categoriesButtonTitle = categoriesButtonTitle + "\(category.string), "
                }
            }
        }
        
        categoriesButton.setTitle(categoriesButtonTitle, for: .normal)
        categoriesButton.titleLabel?.textAlignment = .center
    }
    
    // MARK: - Expiration, Bought or Opened date
    
    // MARK: - Expiration, Bought or Opened date - IBActions
    
    @IBAction func expirationDatePressed(_ sender: Any) {
        hideDatePickerView(hide: false)
    }
    
    @IBAction func dismissDatePickerPressed(_ sender: Any) {
        hideDatePickerView(hide: true)
    }
    
    @IBAction func cancelDatePickerPressed(_ sender: Any) {
        hideDatePickerView(hide: true)
    }
    
    @IBAction func saveDatePickerPressed(_ sender: Any) {
        expirationdate = expirationDatePicker.date
        
        hideDatePickerView(hide: true)
    }
    
    // MARK: - Expiration, Bought or Opened date - Private Helpers
    
    func hideDatePickerView(hide: Bool) {
        dismissDatePickerButton.isHidden = hide
        datePickerView.isHidden = hide
        
        if let date = expirationdate {
            expirationDateButton.setTitle(UtilsManager.shared.dateFormatter.string(from: date), for: .normal)
        }
    }
    
    // MARK: - Unit
    
    // MARK: - Unit - IBActions
    
    @IBAction func unitPressed(_ sender: Any) {
        copyOfSelectedUnit = selectedUnit
        
        unitsTableView.reloadData()
        
        hideUnitView(hide: false)
    }
    
    @IBAction func dismissUnitViewPressed(_ sender: Any) {
        hideUnitView(hide: true)
    }
    
    @IBAction func cancelUnitViewPressed(_ sender: Any) {
        hideUnitView(hide: true)
    }
    
    @IBAction func saveUnitViewPressed(_ sender: Any) {
        selectedUnit = copyOfSelectedUnit
        
        hideUnitView(hide: true)
    }
    
    // MARK: - Unit - Private Helpers
    
    private func hideUnitView(hide: Bool) {
        dismissUnitViewButton.isHidden = hide
        unitView.isHidden = hide
        
        configureUnitButton()
    }
    
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
            expirationdate = UtilsManager.shared.dateFormatter.date(from: expDate)
        }
        
        quantityTextField.text = "\(ingredient.quantity ?? 0.0)"
        
        if let unit = ingredient.unit {
            selectedUnit = unit
            unitButton.setTitle(unit, for: .normal)
        }
        
        selectedCategories = ingredient.ingredientCategories
        allIngredientCategoriesAsString = ingredient.categories
        categoriesButton.setTitle("\(ingredient.categories ?? "Categories")", for: .normal)
    }
}

extension HomeIngredientDetailsView:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == unitsTableView {
            if section == 0 {
                return volumeUnits.count
            } else {
                return massAndWeightUnits.count
            }
        } else {
            return IngredientCategories.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == categoriesTableView {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
            
            cell.textLabel?.text = IngredientCategory.categoryNameForIndex(index: indexPath.row)
            
            if copyOfSelectedCategories.contains(where: { (category) -> Bool in
                return category.index == indexPath.row
            }) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "unitCell")
            
            if indexPath.section == 0 {
                cell.textLabel?.text = volumeUnits[indexPath.row]
                
                if let unit = copyOfSelectedUnit,
                    volumeUnits.contains(unit),
                    indexPath.row == volumeUnits.firstIndex(of: unit) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            } else {
                cell.textLabel?.text = massAndWeightUnits[indexPath.row]
                
                if let unit = copyOfSelectedUnit,
                    massAndWeightUnits.contains(unit),
                    indexPath.row == massAndWeightUnits.firstIndex(of: unit) {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == categoriesTableView {
            let selectedCategory = IngredientCategories.allCases.first { (ingredient) -> Bool in
                return ingredient.index == indexPath.row
            }
            
            guard let category = selectedCategory else { return }
            
            if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
                
                if copyOfSelectedCategories.contains(category) {
                    let categoryIndex = copyOfSelectedCategories.firstIndex(of: category)
                    
                    if let index = categoryIndex {
                        copyOfSelectedCategories.remove(at: index)
                    }
                }
            } else {
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
                
                copyOfSelectedCategories.append(category)
            }
        } else {
            if let unit = copyOfSelectedUnit {
                if let selectedVolumeUnitIndex = volumeUnits.firstIndex(of: unit)  {
                    tableView.cellForRow(at: IndexPath(item: selectedVolumeUnitIndex, section: 0))?.accessoryType = .none
                } else if let selectedMassAndWeightUnitIndex = massAndWeightUnits.firstIndex(of: unit) {
                    tableView.cellForRow(at: IndexPath(item: selectedMassAndWeightUnitIndex, section: 1))?.accessoryType = .none
                }
            }
            
            if indexPath.section == 0 {
                copyOfSelectedUnit = volumeUnits[indexPath.row]
                
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            } else {
                copyOfSelectedUnit = massAndWeightUnits[indexPath.row]
                
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
            
            selectedUnit = copyOfSelectedUnit
            
            hideUnitView(hide: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView == unitsTableView {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == unitsTableView ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == unitsTableView {
            return section == 0 ? "Volume" : "Mass and Weight"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
