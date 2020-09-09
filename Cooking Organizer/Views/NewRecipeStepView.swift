//
//  NewRecipeStepView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol NewRecipeStepViewDelegate: class {
    func deletedPressed(fromView view: NewRecipeStepView)
}

class NewRecipeStepView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var stepTextView: UITextView!
    @IBOutlet weak var stepNumberLabel: UILabel!
    
    weak var delegate: NewRecipeStepViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("NewRecipeStepView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5
        
        stepTextView.text = ""
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        if let stepNumberAsString = stepNumberLabel.text, let stepNumber = NumberFormatter().number(from: stepNumberAsString) {
            delegate?.deletedPressed(fromView: self)
        }
    }
}
