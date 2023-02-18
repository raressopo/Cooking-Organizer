//
//  RecipeTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            self.nameLabel.font = UIFont(name: FontName.bold.rawValue, size: 22.0)
        }
    }
    
    @IBOutlet weak var portionsLabel: UILabel! {
        didSet {
            portionsLabel.font = UIFont(name: FontName.bold.rawValue, size: 16.0)
        }
    }
    
    @IBOutlet weak var cookingTimeLabel: UILabel! {
        didSet {
            self.cookingTimeLabel.adjustsFontSizeToFitWidth = true
            self.cookingTimeLabel.minimumScaleFactor = 0.2
            cookingTimeLabel.font = UIFont(name: FontName.bold.rawValue, size: 16.0)
        }
    }
    
    @IBOutlet weak var lastCookLabel: UILabel! {
        didSet {
            self.lastCookLabel.adjustsFontSizeToFitWidth = true
            self.lastCookLabel.minimumScaleFactor = 0.2
            lastCookLabel.font = UIFont(name: FontName.bold.rawValue, size: 16.0)
        }
    }
    
    @IBOutlet weak var categoriesLabel: UILabel! {
        didSet {
            categoriesLabel.font = UIFont(name: FontName.bold.rawValue, size: 16.0)
        }
    }
    
    @IBOutlet weak var dificultyLabel: UILabel! {
        didSet {
            dificultyLabel.font = UIFont(name: FontName.bold.rawValue, size: 16.0)
        }
    }
    
    @IBOutlet weak var recipeImageView: UIImageView! {
        didSet {
            self.recipeImageView.layer.cornerRadius = self.recipeImageView.frame.height / 2
            self.recipeImageView.contentMode = .scaleAspectFill
            self.recipeImageView.layer.borderWidth = 3.0
            self.recipeImageView.layer.borderColor = UIColor.imageBorder().cgColor
        }
    }
    
    @IBOutlet weak var containerView: UIView! {
        didSet {
            self.containerView.layer.cornerRadius = 16.0
        }
    }
    
    @IBOutlet var subtitlesConstraints: [NSLayoutConstraint]!
    @IBOutlet var subtitleLabels: [UILabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10.0
        
        subtitleLabels.forEach({ $0.font = UIFont(name: FontName.thin.rawValue, size: 16.0) })
    }
    
    static func recipeCellHeight(forString string: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height: 300))
        
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.numberOfLines = 5
        
        return string.size(for: label).height
    }
    
    func configure(withName name: String, portions: Int, lastCooking: String?, cookingTime: String?, dificulty: String?, categories: String, image: UIImage?) {
        self.portionsLabel.text = portions > 0 ? "\(portions)" : "Not Set"
        self.lastCookLabel.text = "\(lastCooking ?? "Not Set")"
        self.cookingTimeLabel.text = "\(cookingTime ?? "Not Set")"
        self.dificultyLabel.text = "\(dificulty ?? "Not Set")"
        self.categoriesLabel.text = categories
        self.recipeImageView.image = image
        self.nameLabel.text = name
        
        recipeImageView.isHidden = image == nil
        
        subtitlesConstraints.forEach({ $0.constant = image == nil ? 10 : 140 })
    }
}
