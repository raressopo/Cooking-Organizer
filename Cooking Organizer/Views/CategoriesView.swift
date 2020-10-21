//
//  CategoriesView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 17/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol CategoriesViewDelegate: class {
    func didSelectCategories(categories: [RecipeCategories])
    func didSelectRecipeCategory(withCategoryName name: String)
    
    func didSelectHICategory(withCategoryName name: String)
    func didSelectIngredientCategory(withCategory category: IngredientCategories)
}

extension CategoriesViewDelegate {
    func didSelectCategories(categories: [RecipeCategories]) {}
    func didSelectRecipeCategory(withCategoryName name: String) {}
    
    func didSelectHICategory(withCategoryName name: String) {}
    func didSelectIngredientCategory(withCategory category: IngredientCategories) {}
}

class CategoriesView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    var copyOfSelectedCategories = [RecipeCategories]()
    
    weak var delegate: CategoriesViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("CategoriesView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissViewPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        delegate?.didSelectCategories(categories: copyOfSelectedCategories)
        
        removeFromSuperview()
    }
}

// MARK: - Recipe Categories View

class RecipeCategoriesView: CategoriesView {
    var isRecipeCategorySelection = false {
        didSet {
            buttonsStackView.isHidden = isRecipeCategorySelection
        }
    }
    var selectedRecipeCategory: String?
    
    override func commonInit() {
        super.commonInit()
        
        if isRecipeCategorySelection {
            buttonsStackView.isHidden = true
        }
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
}

extension RecipeCategoriesView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecipeCategories.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        
        cell.textLabel?.text = RecipeCategory.categoryNameForIndex(index: indexPath.row)
        cell.selectionStyle = .none
        
        if isRecipeCategorySelection {
            if let categoryName = selectedRecipeCategory, categoryName == RecipeCategory.categoryNameForIndex(index: indexPath.row) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        } else {
            if copyOfSelectedCategories.contains(where: { (category) -> Bool in
                return category.index == indexPath.row
            }) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isRecipeCategorySelection {
            delegate?.didSelectRecipeCategory(withCategoryName: RecipeCategory.categoryNameForIndex(index: indexPath.row))
            
            removeFromSuperview()
        } else {
            let selectedCategory = RecipeCategories.allCases.first { (ingredient) -> Bool in
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
        }
    }
}

// MARK: - Home Ingredients Categories View

class HomeIngredientsCategoriesView: CategoriesView {
    var selectedCategoryName: String?
    
    override func commonInit() {
        super.commonInit()
        
        buttonsStackView.isHidden = true
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
}

extension HomeIngredientsCategoriesView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IngredientCategories.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        
        cell.textLabel?.text = IngredientCategory.categoryNameForIndex(index: indexPath.row)
        
        if let name = selectedCategoryName, name == IngredientCategory.categoryNameForIndex(index: indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectHICategory(withCategoryName: IngredientCategory.categoryNameForIndex(index: indexPath.row))
        delegate?.didSelectIngredientCategory(withCategory: IngredientCategories.allCases[indexPath.row])
        
        removeFromSuperview()
    }
}
