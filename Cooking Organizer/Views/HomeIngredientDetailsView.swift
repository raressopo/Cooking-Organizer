//
//  HomeIngredientDetailsView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 05/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeIngredientDetailsView: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var dismissIngredientDetailsButton: UIButton!
    @IBOutlet weak var ingredientDetailsView: UIView!
    @IBOutlet weak var ingredientNameTextField: UITextField!
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
    }
    
    @IBAction func createChangedPressed(_ sender: Any) {
        if createButton.titleLabel?.text == "Create" {
            guard let ingredientName = ingredientNameTextField.text else {
                // ERROR
                return
            }
            
            guard let ingredientQuantity = quantityTextField.text else {
                // ERROR
                return
            }
            
            guard let ingredientQuantityAsNumber = NumberFormatter().number(from: ingredientQuantity), let quantity = ingredientQuantityAsNumber as? Double else {
                // ERROR
                return
            }
            
            if let loggedInUser = UsersManager.shared.currentLoggedInUser, let userId = loggedInUser.id {
                let uuid = UUID().uuidString
                
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
                
                Database.database().reference().child("usersData").child(userId).child("homeIngredients").child(uuid).setValue(["name": ingredientName,
                                                                                                                                "expirationDate": UtilsManager.shared.dateFormatter.string(from: expirationdate ?? Date(timeIntervalSince1970: 0)),
                                                                                                                                "quantity": quantity,
                                                                                                                                "unit": selectedUnit ?? "",
                                                                                                                                "categories": categoriesAsString]) { (error, ref) in
                                                                                                                                    if error == nil {
                                                                                                                                        self.removeFromSuperview()
                                                                                                                                    } else {
                                                                                                                                        // ERROR
                                                                                                                                    }
                }
            }
        } else {
            var ingredientChanged = false
            
            var changedDataDictionary = [String:Any]()
            
            guard let ingredient = homeIngredient else {
                // ERROR
                return
            }
            
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
            
            if let categoriesAsString = allIngredientCategoriesAsString, ingredient.categoriesAsString != categoriesAsString {
                changedDataDictionary["categories"] = categoriesAsString
                
                ingredientChanged = true
            }
            
            if ingredientChanged {
                if let loggedInUser = UsersManager.shared.currentLoggedInUser, let userId = loggedInUser.id, let ingredientId = ingredient.id {
                    Database.database().reference().child("usersData")
                        .child(userId).child("homeIngredients")
                        .child(ingredientId)
                        .updateChildValues(changedDataDictionary, withCompletionBlock: { (error, ref) in
                            self.removeFromSuperview()
                        }
                    )}
            } else {
                // ALERT
                
                return
            }
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func dismissIngredientDetailsPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
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
    
    // MARK: - Categories - Helpers
    
    func hideCategoriesView(hide: Bool) {
        dismissCategoriesButton.isHidden = hide
        categoriesView.isHidden = hide
    }
    
    func configureCategoriesButton() {
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
    
    func hideDatePickerView(hide: Bool) {
        dismissDatePickerButton.isHidden = hide
        datePickerView.isHidden = hide
        
        if let date = expirationdate {
            expirationDateButton.setTitle(UtilsManager.shared.dateFormatter.string(from: date), for: .normal)
        }
    }
    
    // MARK: - Unit
    
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
    
    func hideUnitView(hide: Bool) {
        dismissUnitViewButton.isHidden = hide
        unitView.isHidden = hide
        
        configureUnitButton()
    }
    
    func configureUnitButton() {
        if let unit = selectedUnit {
            unitButton.setTitle(unit, for: .normal)
        } else {
            unitButton.setTitle("Unit", for: .normal)
        }
    }
    
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
        
        selectedCategories = ingredient.categories
        allIngredientCategoriesAsString = ingredient.categoriesAsString
        categoriesButton.setTitle("\(ingredient.categoriesAsString ?? "Categories")", for: .normal)
    }
}
