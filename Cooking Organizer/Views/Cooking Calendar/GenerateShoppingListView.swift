//
//  GenerateShoppingListView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 05/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import CodableFirebase

class GenerateShoppingListView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var startDateButton: UIButton!
    @IBOutlet weak var endDateButton: UIButton!
    
    var startDate: Date?
    var endDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GenerateShoppingListView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func generatePressed(_ sender: Any) {
        guard let recipes = UsersManager.shared.currentLoggedInUser?.recipes else { return }
        
        var rangedRecipes = [Recipe]()
        
        for recipe in recipes {
            for recipeCookingDate in recipe.cookingDatesAsDates {
                if let sDate = startDate,
                   let eDate = endDate,
                   UtilsManager.isSelectedDate(selectedDate: recipeCookingDate, inFutureOrInPresentToGivenDate: sDate),
                   UtilsManager.isSelectedDate(selectedDate: recipeCookingDate, inPastOrInPresentToGivenDate: eDate) {
                    rangedRecipes.append(recipe)
                }
            }
        }
        
        var recipesIngredients = [GeneratedShoppingListItem]()
        
        for recipe in rangedRecipes {
            if let ingredients = recipe.ingredients {
                for ingredient in ingredients {
                    let existingIngredientIndex = recipesIngredients.firstIndex(where: {$0.name == ingredient.name})
                    
                    if let index = existingIngredientIndex,
                       let existingQuantity = recipesIngredients[index].quantity,
                       let ingredientQuantity = ingredient.quantityAsDouble {
                        recipesIngredients[index].quantity = existingQuantity + ingredientQuantity
                    } else {
                        recipesIngredients.append(GeneratedShoppingListItem(name: ingredient.name,
                                                                            quantity: ingredient.quantityAsDouble,
                                                                            unit: ingredient.unit,
                                                                            bought: false))
                    }
                }
            }
        }
        
        if let homeIngredients = UsersManager.shared.currentLoggedInUser?.homeIngredients {
            for homeIngredient in homeIngredients {
                let existingIngredientIndex = recipesIngredients.firstIndex(where: {$0.name == homeIngredient.name})
                
                if let index = existingIngredientIndex,
                   let existingQuantity = recipesIngredients[index].quantity,
                   let homeIngredientQuantity = homeIngredient.quantity {
                    let remaningQuantity = existingQuantity - homeIngredientQuantity
                    
                    if remaningQuantity <= 0 {
                        recipesIngredients.remove(at: index)
                    } else {
                        recipesIngredients[index].quantity = remaningQuantity
                    }
                }
            }
        }
        
        if let sDate = startDate, let eDate = endDate {
            var recipesIngredientsDict = [String: GeneratedShoppingListItem]()
            
            for ingredient in recipesIngredients {
                recipesIngredientsDict[ingredient.name ?? "Unknown"] = ingredient
            }
            
            do {
                let data = try FirebaseEncoder().encode(recipesIngredientsDict)
                
                let startDateString = UtilsManager.shared.dateFormatter.string(from: sDate)
                let endDateString = UtilsManager.shared.dateFormatter.string(from: eDate)
                
                UserDataManager.shared.createShoppingList(withName: UtilsManager.isSelectedDate(selectedDate: sDate, equalToGivenDate: eDate) ? "\(startDateString)" : "\(startDateString) - \(endDateString)",
                                                          andValues: ["name": UtilsManager.isSelectedDate(selectedDate: sDate, equalToGivenDate: eDate) ? "\(startDateString)" : "\(startDateString) - \(endDateString)",
                                                                      "items": data as Any]) {
                    self.removeFromSuperview()
                } failure: {
                    self.removeFromSuperview()
                }

            } catch {
                if let parentVC = self.window?.rootViewController?.presentedViewController {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC,
                                                                      title: "Creation Failed",
                                                                      message: "Something went wrong creating the Shopping List. Please try again!")
                    
                    return
                }
            }
        }
    }
    
    @IBAction func startDatePressed(_ sender: Any) {
        let datePickerView = SelectDatePickerView()
        
        datePickerView.isStartDate = true
        datePickerView.delegate = self
        
        contentView.addSubview(datePickerView)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([datePickerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
                                     datePickerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
                                     datePickerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
                                     datePickerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func endDatePressed(_ sender: Any) {
        let datePickerView = SelectDatePickerView()
        
        datePickerView.isStartDate = false
        datePickerView.delegate = self
        
        contentView.addSubview(datePickerView)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([datePickerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
                                     datePickerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
                                     datePickerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
                                     datePickerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)])
    }
}

extension GenerateShoppingListView: SelectDatePickerViewDelegate {
    func didSelectDate(date: Date?, forStartDate startDate: Bool) {
        guard let selectedDate = date else { return }
        
        if startDate {
            if let eDate = endDate,
               !UtilsManager.isSelectedDate(selectedDate: eDate, inFutureOrInPresentToGivenDate: selectedDate),
               let parentVC = self.window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC,
                                                                  title: "Invalid Start Date",
                                                                  message: "Please select a valid start date that should be before or at least the same date as end date!")
                
                return
            } else {
                self.startDate = selectedDate
            
                startDateButton.setTitle(UtilsManager.shared.dateFormatter.string(from: selectedDate), for: .normal)
            }
        } else {
            if let sDate = self.startDate,
               !UtilsManager.isSelectedDate(selectedDate: selectedDate, inFutureOrInPresentToGivenDate: sDate),
               let parentVC = self.window?.rootViewController?.presentedViewController {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: parentVC,
                                                                  title: "Invalid End Date",
                                                                  message: "Please select a valid start date that should be before or at least the same date as end date!")
                
                return
            } else {
                endDate = selectedDate
                
                endDateButton.setTitle(UtilsManager.shared.dateFormatter.string(from: selectedDate), for: .normal)
            }
        }
    }
}
