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
}

class CategoriesView: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var categoriesTableView: UITableView!
    
    weak var delegate: CategoriesViewDelegate?
    
    var copyOfSelectedCategories = [RecipeCategories]()
    
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
        
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecipeCategories.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        
        cell.textLabel?.text = RecipeCategory.categoryNameForIndex(index: indexPath.row)
        cell.selectionStyle = .none
        
        if copyOfSelectedCategories.contains(where: { (category) -> Bool in
            return category.index == indexPath.row
        }) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
