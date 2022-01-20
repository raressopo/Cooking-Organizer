//
//  IngredientsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

protocol CreateRecipeIngredientsProtocol: AnyObject {
    func ingredientsAdded(ingredients: [NewRecipeIngredient])
}

class IngredientsViewController: UIViewController {
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var addIngredientButton: UIButton!
    
    @IBOutlet weak var ingredientsTableViewBottomToButtonConstraint: NSLayoutConstraint!
    
    var ingredientsTableViewBottomToScreenBottomConstraint: NSLayoutConstraint?
    
    lazy var ingredients = [NewRecipeIngredient]()
    lazy var ingredientsCopy = [NewRecipeIngredient]()
    lazy var createRecipeIngredients = [NewRecipeIngredient]()
    
    var recipe: Recipe?
    
    var createRecipeMode = false
    
    weak var delegate: CreateRecipeIngredientsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ingredientsTableView.delegate = self
        ingredientsTableView.dataSource = self
        
        ingredientsTableView.register(UINib(nibName: "RecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "ingredientCell")
        ingredientsTableView.register(UINib(nibName: "ChangeRecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "changeIngredientCell")
        
        if createRecipeMode {
            let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
            
            self.navigationItem.hidesBackButton = true
            self.navigationItem.rightBarButtonItem = editNavBarButton
            
            ingredientsTableView.setEditing(true, animated: false)
        } else {
            ingredientsTableViewBottomToButtonConstraint.isActive = false
            addIngredientButton.isHidden = true
            
            ingredientsTableViewBottomToScreenBottomConstraint = ingredientsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ingredientsTableViewBottomToScreenBottomConstraint?.isActive = true
            
            let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
            
            self.navigationItem.rightBarButtonItem = editNavBarButton
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = false
    }
    
    @IBAction func addIngredientPressed(_ sender: Any) {
        let ingredient = NewRecipeIngredient()
        
        if createRecipeMode {
            createRecipeIngredients.append(ingredient)
        } else {
            ingredientsCopy.append(ingredient)
        }
        
        ingredientsTableView.reloadData()
    }
    
    @objc private func donePressed() {
        validateChangedIngredients { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Ingredients",
                                                                  message: "Please complete all the info for all the ingredients you have or added.")
            } else {
                self.delegate?.ingredientsAdded(ingredients: self.createRecipeIngredients)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func editPressed() {
        setEditMode(editMode: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
        self.navigationItem.hidesBackButton = true
    }
    
    @objc private func savePressed() {
        validateChangedIngredients { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Ingredients",
                                                                  message: "Please complete all the info for all the ingredients you have or added.")
                
                return
            } else {
                var changedIngredients = [String:Any]()
                
                if self.areIngredientsChanged() { self.ingredientsCopy.forEach { changedIngredients["\(self.ingredientsCopy.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
                } else {
                    self.setEditMode(editMode: false)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                    self.navigationItem.hidesBackButton = false
                    
                    return
                }
                
                if let userId = UsersManager.shared.currentLoggedInUser?.loginData.id,
                    let recipeId = self.recipe?.id {
                    
                    FirebaseAPIManager.sharedInstance.updateRecipe(froUserId: userId,
                                                                   andForRecipeId: recipeId,
                                                                   withDetails: ["ingredients":changedIngredients]) { success in
                                                                    if success {
                                                                        self.recipe = UsersManager.shared.currentLoggedInUser!.data.recipes?[recipeId]
                                                                        
                                                                        self.refreshIngredients()
                                                                        
                                                                        self.setEditMode(editMode: false)
                                                                        
                                                                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                                                                        self.navigationItem.hidesBackButton = false
                                                                    } else {
                                                                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                                                                          title: "Update Failed",
                                                                                                                          message: "Something went wrong updating the recipe. Please try again later!")
                                                                    }
                    }
                } else {
                    self.setEditMode(editMode: false)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                    self.navigationItem.hidesBackButton = false
                }
            }
        }
    }
    
    func setEditMode(editMode: Bool) {
        ingredientsTableView.setEditing(editMode, animated: true)
        
        if editMode {
            showAddIngredientButton()
            populateIngredientsCopy()
            
            ingredientsTableView.reloadData()
        } else {
            hideAddIngredientButton()
            
            ingredientsTableView.reloadData()
        }
    }
    
    private func hideAddIngredientButton() {
        addIngredientButton.isHidden = true
        
        ingredientsTableViewBottomToButtonConstraint.isActive = false
        ingredientsTableViewBottomToScreenBottomConstraint?.isActive = true
    }
    
    private func showAddIngredientButton() {
        addIngredientButton.isHidden = false
        
        ingredientsTableViewBottomToButtonConstraint = ingredientsTableView.bottomAnchor.constraint(equalTo: addIngredientButton.topAnchor)
        ingredientsTableViewBottomToButtonConstraint.isActive = true
        
        ingredientsTableViewBottomToScreenBottomConstraint?.isActive = false
    }
    
    private func populateIngredientsCopy() {
        ingredientsCopy.removeAll()
        
        for ingredient in ingredients {
            let ingredientCopy = NewRecipeIngredient()
            
            ingredientCopy.name = ingredient.name
            ingredientCopy.quantity = ingredient.quantity
            ingredientCopy.unit = ingredient.unit
            
            ingredientsCopy.append(ingredientCopy)
        }
    }
    
    func validateChangedIngredients(validationFailed completion: @escaping (Bool) -> Void) {
        removeEmptyIngredients()
        
        for ingredient in ingredientsCopy {
            guard ingredient.name != nil,
                  ingredient.unit != nil,
                  ingredient.quantity != nil else {
                completion(true)
                
                return
            }
        }
        
        completion(false)
    }
    
    private func removeEmptyIngredients() {
        if createRecipeMode {
            for ingredient in createRecipeIngredients where (ingredient.name == nil && ingredient.unit == nil && ingredient.quantity == nil) {
                let ingredientIndex = createRecipeIngredients.lastIndex(of: ingredient)
                
                if let index = ingredientIndex {
                    createRecipeIngredients.remove(at: index)
                }
            }
        } else {
            for ingredient in ingredientsCopy where (ingredient.name == nil && ingredient.unit == nil && ingredient.quantity == nil) {
                let ingredientIndex = ingredientsCopy.lastIndex(of: ingredient)
                
                if let index = ingredientIndex {
                    ingredientsCopy.remove(at: index)
                }
            }
        }
    }
    
    func areIngredientsChanged() -> Bool {
        if ingredients != ingredientsCopy {
            return true
        } else {
            for index in ingredients.indices {
                if ingredients[index].name != ingredientsCopy[index].name ||
                    ingredients[index].unit != ingredientsCopy[index].unit ||
                    ingredients[index].quantity != ingredientsCopy[index].quantity {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func refreshIngredients() {
        if let recipeIngredients = recipe?.ingredients, recipeIngredients.count > 0 {
            ingredients = recipeIngredients
        }
    }
    
}

extension IngredientsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if createRecipeMode {
            return createRecipeIngredients.count
        } else {
            return tableView.isEditing ? ingredientsCopy.count : ingredients.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            let ingredient = createRecipeMode ? createRecipeIngredients[indexPath.row] : ingredientsCopy[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "changeIngredientCell") as? ChangeRecipeIngredientCell else {
                fatalError("Cell type is not ChangeRecipeIngredientCell")
            }
            
            cell.ingredient = ingredient
            cell.index = indexPath.row
            
            cell.ingredientNameTextField.text = ingredient.name
            cell.quantityTextField.text = ingredient.quantity
            cell.unitButton.setTitle(ingredient.unit ?? "Unit", for: .normal)
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let ingredient = ingredients[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as? RecipeIngredientCell else {
                fatalError("Cell type is not RecipeIngredientCell")
            }
            
            cell.nameLabel.text = ingredient.name
            
            if let quantity = ingredient.quantity,
               let unit = ingredient.unit {
                cell.quantityUnitLabel.text = quantity + " " + unit
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedIngredient = createRecipeMode ? createRecipeIngredients[sourceIndexPath.row] : ingredientsCopy[sourceIndexPath.row]
        
        if createRecipeMode {
            createRecipeIngredients.remove(at: sourceIndexPath.row)
            createRecipeIngredients.insert(movedIngredient, at: destinationIndexPath.row)
        } else {
            ingredientsCopy.remove(at: sourceIndexPath.row)
            ingredientsCopy.insert(movedIngredient, at: destinationIndexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if createRecipeMode {
                createRecipeIngredients.remove(at: indexPath.row)
            } else {
                ingredientsCopy.remove(at: indexPath.row)
            }
            
            tableView.reloadData()
        }
    }
    
}
