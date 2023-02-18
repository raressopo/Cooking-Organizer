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
    @IBOutlet weak var recipeNameLabel: UILabel! {
        didSet {
            recipeNameLabel.adjustsFontSizeToFitWidth = true
            recipeNameLabel.numberOfLines = 3
            recipeNameLabel.font = UIFont(name: "Proxima Nova Alt Bold", size: 18.0)
        }
    }
    @IBOutlet weak var nrOfIngredientsLabel: UILabel! {
        didSet {
            nrOfIngredientsLabel.font = UIFont(name: "Proxima Nova Alt Light", size: 15.0)
        }
    }
    @IBOutlet weak var scheduleButton: UIButton! {
        didSet {
            scheduleButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            scheduleButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 15.0)
            scheduleButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
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
