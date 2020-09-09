//
//  RecipeDetailsStepView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 22/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsStepView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var stepNr: UILabel!
    @IBOutlet weak var stepDescription: UITextView!
    
    @IBOutlet weak var checkboxCheckedBlockView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RecipeDetailsStepView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        checkbox.checkmarkStyle = .tick
        checkbox.borderStyle = .circle
        checkbox.checkedBorderColor = .systemGray5
        checkbox.checkmarkColor = .darkGray

        checkbox.addTarget(self, action: #selector(checkboxChanged), for: .valueChanged)
    }
    
    @objc func checkboxChanged() {
        checkboxCheckedBlockView.isHidden = !checkbox.isChecked
    }
}
