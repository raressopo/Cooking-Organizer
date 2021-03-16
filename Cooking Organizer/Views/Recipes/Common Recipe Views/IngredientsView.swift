//
//  RecipeDetailsTableViews.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol IngredientsViewDelegate: class {
    func ingredientDeleted()
}

class IngredientsView: UIView {
    var tableView = UITableView()
    var addIngredientButton = UIButton()
    
    var ingredients = [NewRecipeIngredient]()
    var ingredientsCopy = [NewRecipeIngredient]()
    
    weak var delegate: IngredientsViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        populateIngredientsCopy()
        setupTableView()
    }
    
    // MARK: - Helpers
    
    func setEditMode(editMode: Bool) {
        tableView.setEditing(editMode, animated: true)
        
        if editMode {
            setupAddIngredientButton()
            populateIngredientsCopy()
            
            tableView.reloadData()
        } else {
            removeAddIngredientButton()
            
            tableView.reloadData()
        }
    }
    
    func validateChangedIngredients(validationFailed completion: @escaping (Bool) -> Void) {
        removeEmptyIngredients()
        
        for ingredient in ingredientsCopy {
            guard let _ = ingredient.name,
                let _ = ingredient.unit,
                let _ = ingredient.quantity else
            {
                completion(true)
                
                return
            }
        }
        
        completion(false)
    }
    
    func areIngredientsChanged() -> Bool {
        if ingredients != ingredientsCopy {
            return true
        } else {
            for index in ingredients.indices {
                if ingredients[index].name != ingredientsCopy[index].name ||
                    ingredients[index].unit != ingredientsCopy[index].unit ||
                    ingredients[index].quantity != ingredientsCopy[index].quantity
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private Helpers
    
    private func setupTableView() {
        tableView = UITableView()
        
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        constraintsSetup(inEditMode: false)
        
        tableView.register(UINib(nibName: "RecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "ingredientCell")
        tableView.register(UINib(nibName: "ChangeRecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "changeIngredientCell")
    }
    
    private func removeEmptyIngredients() {
        for ingredient in ingredientsCopy {
            if ingredient.name == nil,
                ingredient.unit == nil,
                ingredient.quantity == nil
            {
                let ingredientIndex = ingredientsCopy.lastIndex(of: ingredient)
                
                if let index = ingredientIndex {
                    ingredientsCopy.remove(at: index)
                }
            }
        }
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
    
    private func setupAddIngredientButton() {
        addIngredientButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        addIngredientButton.setTitle("+ Add Ingredient", for: .normal)
        addIngredientButton.setTitleColor(.systemBlue, for: .normal)
        addIngredientButton.addTarget(self, action: #selector(addIngredienPressed), for: .touchUpInside)
        
        addSubview(addIngredientButton)
        
        addIngredientButton.translatesAutoresizingMaskIntoConstraints = false
        
        constraintsSetup(inEditMode: true)
    }
    
    private func removeAddIngredientButton() {
        addIngredientButton.removeFromSuperview()
        
        constraintsSetup(inEditMode: false)
    }
    
    private func constraintsSetup(inEditMode editMode: Bool) {
        removeConstraints(constraints)
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if editMode {
            tableView.bottomAnchor.constraint(equalTo: addIngredientButton.topAnchor).isActive = true
            
            addIngredientButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            addIngredientButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
            addIngredientButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
            addIngredientButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    // MARK: - Selectors
    
    @objc
    private func addIngredienPressed() {
        let ingredient = NewRecipeIngredient()
        
        ingredientsCopy.append(ingredient)
        
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate and DataSource

extension IngredientsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? ingredientsCopy.count : ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            let ingredient = ingredientsCopy[indexPath.row]
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "changeIngredientCell") as? ChangeRecipeIngredientCell else {
                fatalError("Cell type is not ChangeRecipeIngredientCell")
            }
            
            cell.ingredient = ingredient
            
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
                let unit = ingredient.unit
            {
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
        let movedIngredient = ingredientsCopy[sourceIndexPath.row]
        
        ingredientsCopy.remove(at: sourceIndexPath.row)
        ingredientsCopy.insert(movedIngredient, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            ingredientsCopy.remove(at: indexPath.row)
            
            delegate?.ingredientDeleted()
            
            tableView.reloadData()
        }
    }
}
