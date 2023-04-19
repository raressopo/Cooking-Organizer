//
//  NewRecipeSectionHeaderView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/04/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

protocol NewRecipeSectionHeaderViewDelegate: AnyObject {
    func textFieldDidChanged(forSectionHeader section: NewRecipeSection, andText text: String)
}

class NewRecipeSectionHeaderView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var headerTextfield: UITextField!
    @IBOutlet weak var changeAddButton: UIButton! {
        didSet {
            self.changeAddButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#B46617"), for: .normal)
            self.changeAddButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
            self.changeAddButton.contentHorizontalAlignment = .right
        }
    }
    
    weak var delegate: NewRecipeSectionHeaderViewDelegate?
    
    var section: NewRecipeSection?
    
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
        
        self.headerTextfield.delegate = self
    }
    
    func configure(withNewRecipeSection section: NewRecipeSection,
                   andDelegate delegate: NewRecipeSectionHeaderViewDelegate,
                   withAddButton displayAddButton: Bool) {
        self.section = section
        self.delegate = delegate
        
        changeAddButton.setTitle(displayAddButton == true ? "Add" : "Change", for: .normal)
        
        self.sectionTitleLabel.text = "\(section.rawValue):"
        
        switch section {
        case .name:
            headerTextfield.isHidden = true
            changeAddButton.isHidden = true
        case .portions:
            self.headerTextfield.borderStyle = .none
            self.headerTextfield.layer.cornerRadius = 10.0
            self.headerTextfield.placeholder = "No. of Portions"
            self.headerTextfield.backgroundColor = UIColor.hexStringToUIColor(hex: "#88AA8D").withAlphaComponent(0.7)
            self.headerTextfield.textAlignment = .center
            self.headerTextfield.keyboardType = .numberPad
            self.headerTextfield.isHidden = false
            self.changeAddButton.isHidden = true
        default:
            headerTextfield.isHidden = true
            changeAddButton.isHidden = false
        }
    }
}

extension NewRecipeSectionHeaderView: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let section = self.section, let text = textField.text {
            self.delegate?.textFieldDidChanged(forSectionHeader: section, andText: text)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentView.endEditing(true)
    }
    
}