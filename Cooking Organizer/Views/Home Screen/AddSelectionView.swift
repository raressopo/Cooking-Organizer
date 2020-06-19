//
//  AddSelectionView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 10/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class AddSelectionView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var homeIngredientButton: UIButton!
    @IBOutlet weak var recipeButton: UIButton!
    @IBOutlet weak var dismissSelectionViewButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("AddSelectionView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissSelectionViewPressed(_ sender: Any) {
        removeFromSuperview()
    }
}
