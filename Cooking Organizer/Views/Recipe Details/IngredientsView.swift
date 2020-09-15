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

extension IngredientsViewDelegate {
    func ingredientDeleted() {}
}

class IngredientsView: UIView, UITableViewDelegate, UITableViewDataSource {
    var tableView = UITableView()
    var addIngredientButton = UIButton()
    
    var ingredients = [NewRecipeIngredient]()
    var changingIngredients = [NewRecipeIngredient]()
    
    weak var delegate: IngredientsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAddIngredientButton() {
        addIngredientButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        addIngredientButton.setTitle("+ Add Ingredient", for: .normal)
        addIngredientButton.setTitleColor(.systemBlue, for: .normal)
        addIngredientButton.addTarget(self, action: #selector(addIngredienPressed), for: .touchUpInside)
        
        addSubview(addIngredientButton)
        
        addIngredientButton.translatesAutoresizingMaskIntoConstraints = false
        
        removeConstraints(constraints)
        
        addIngredientButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addIngredientButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
        addIngredientButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
        addIngredientButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addIngredientButton.topAnchor).isActive = true
        
        changingIngredients.removeAll()
        
        for ingredient in ingredients {
            let ingredientCopy = NewRecipeIngredient()
            
            ingredientCopy.name = ingredient.name
            ingredientCopy.quantity = ingredient.quantity
            ingredientCopy.unit = ingredient.unit
            
            changingIngredients.append(ingredientCopy)
        }
    }
    
    @objc
    func addIngredienPressed() {
        let ingredient = NewRecipeIngredient()
        
        changingIngredients.append(ingredient)
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView = UITableView()
        
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        tableView.register(UINib(nibName: "RecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "ingredientCell")
        tableView.register(UINib(nibName: "ChangeRecipeIngredientCell", bundle: nil), forCellReuseIdentifier: "changeIngredientCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? changingIngredients.count : ingredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            let ingredient = changingIngredients[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeIngredientCell") as! ChangeRecipeIngredientCell
            
            cell.ingredient = ingredient
            
            cell.ingredientNameTextField.text = ingredient.name
            cell.quantityTextField.text = ingredient.quantity
            cell.unitButton.setTitle(ingredient.unit ?? "Unit", for: .normal)
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let ingredient = ingredients[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ingredientCell") as! RecipeIngredientCell
            
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
        let movedIngredient = changingIngredients[sourceIndexPath.row]
        changingIngredients.remove(at: sourceIndexPath.row)
        changingIngredients.insert(movedIngredient, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            changingIngredients.remove(at: indexPath.row)
            
            delegate?.ingredientDeleted()
            
            tableView.reloadData()
        }
    }
    
    func removeAddIngredientButton() {
        addIngredientButton.removeFromSuperview()
        
        removeConstraints(constraints)
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func validateChangedIngredients(validationFailed completion: @escaping (Bool) -> Void) {
        for ingredient in changingIngredients {
            if ingredient.name == nil, ingredient.unit == nil, ingredient.quantity == nil {
                let ingredientIndex = changingIngredients.lastIndex(of: ingredient)
                
                if let index = ingredientIndex {
                    changingIngredients.remove(at: index)
                }
            }
        }
        
        tableView.reloadData()
        
        for ingredient in changingIngredients {
            guard let _ = ingredient.name, let _ = ingredient.unit, let _ = ingredient.quantity else {
                completion(true)
                
                return
            }
        }
        
        completion(false)
    }
    
    func areIngredientsChanged() -> Bool {
        if ingredients != changingIngredients {
            return true
        } else {
            for index in ingredients.indices {
                if ingredients[index].name != changingIngredients[index].name || ingredients[index].unit != changingIngredients[index].unit || ingredients[index].quantity != changingIngredients[index].quantity {
                    return true
                }
            }
        }
        
        return false
    }
}
