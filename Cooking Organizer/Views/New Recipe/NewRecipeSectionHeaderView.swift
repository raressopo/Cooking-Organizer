//
//  NewRecipeSectionHeaderView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/04/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

class NewRecipeSectionHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var headerTextfield: UITextField!
    @IBOutlet weak var changeAddButton: UIButton!
    
    // MARK: - Initializers
    init(withFrame frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NewRecipeSectionHeaderView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    func configure(withNewRecipeSection section: NewRecipeSection) {
        sectionTitleLabel.text = "\(section.rawValue):"
        
        switch section {
        case .name:
            headerTextfield.isHidden = true
            changeAddButton.isHidden = true
        case .portions:
            headerTextfield.isHidden = false
            changeAddButton.isHidden = true
        default:
            headerTextfield.isHidden = true
            changeAddButton.isHidden = false
        }
    }
}
