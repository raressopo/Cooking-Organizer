//
//  GeneratedRecipesView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 09/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol GeneratedRecipesViewDelegate: AnyObject {
    func didSelectedRecipeToBeScheduled(recipe: GeneratedRecipe)
}

class GeneratedRecipesView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var generatedRecipesTableView: UITableView!
    
    weak var delegate: GeneratedRecipesViewDelegate?
    
    var generatedRecipes = [GeneratedRecipe]()
    
    var dismissPressed: (() -> Void)?
    
    init(withGeneratedRecipes generatedRecipes: [GeneratedRecipe], andFrame frame: CGRect) {
        super.init(frame: frame)
        
        self.generatedRecipes = generatedRecipes
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("GeneratedRecipesView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        generatedRecipesTableView.delegate = self
        generatedRecipesTableView.dataSource = self
        
        generatedRecipesTableView.register(UINib(nibName: "GeneratedRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "generatedRecipeCell")
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismissPressed?()
        
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismissPressed?()
        
        removeFromSuperview()
    }
}

extension GeneratedRecipesView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return generatedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "generatedRecipeCell") as? GeneratedRecipeTableViewCell else {
            fatalError()
        }
        
        cell.delegate = self
        
        cell.generatedRecipe = generatedRecipes[indexPath.row]
        cell.recipeNameLabel.text = generatedRecipes[indexPath.row].name
        cell.nrOfIngredientsLabel.text = "\(generatedRecipes[indexPath.row].existingIngredients) / \(generatedRecipes[indexPath.row].totalIngredients) ingrds."
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension GeneratedRecipesView: GeneratedRecipeTableViewCellDelegate {
    func didSelectedRecipeToBeScheduled(recipe: GeneratedRecipe) {
        delegate?.didSelectedRecipeToBeScheduled(recipe: recipe)
    }
}
