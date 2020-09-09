//
//  NewRecipeIngredientView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol NewRecipeIngredientViewDelegate: class {
    func deletePressed(fromView view: NewRecipeIngredientView)
    func unitPressed(withView view: NewRecipeIngredientView)
}

class NewRecipeIngredientView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var quantitytextField: UITextField!
    @IBOutlet weak var unitButton: UIButton!
    
    var selectedUnit: String? {
        didSet {
            if let selectedUnit = selectedUnit {
                unitButton.setTitle("\(selectedUnit)", for: .normal)
            } else {
                unitButton.setTitle("Unit", for: .normal)
            }
        }
    }
    
    weak var delegate: NewRecipeIngredientViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NewRecipeIngredientView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        layer.borderWidth = 0.2
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5.0
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        delegate?.deletePressed(fromView: self)
    }
    
    @IBAction func unitPressed(_ sender: Any) {
        delegate?.unitPressed(withView: self)
    }
}
