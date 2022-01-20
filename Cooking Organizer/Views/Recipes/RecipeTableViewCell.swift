//
//  RecipeTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var cookingTimeLabel: UILabel!
    @IBOutlet weak var lastCookLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func recipeCellHeight(forString string: String) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height: 300))
        
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.numberOfLines = 5
        
        return string.size(for: label).height
    }
}
