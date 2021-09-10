//
//  GeneratedRecipeTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 09/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol GeneratedRecipeTableViewCellDelegate: AnyObject {
    func didSelectedRecipeToBeScheduled(recipe: GeneratedRecipe)
}

class GeneratedRecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var recipeNameLabel: UILabel!
    @IBOutlet weak var nrOfIngredientsLabel: UILabel!
    @IBOutlet weak var scheduleButton: UIButton!
    
    weak var delegate: GeneratedRecipeTableViewCellDelegate?
    
    var generatedRecipe: GeneratedRecipe?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func schedulePressed(_ sender: Any) {
        if let recipe = generatedRecipe {
            delegate?.didSelectedRecipeToBeScheduled(recipe: recipe)
        }
    }
}
