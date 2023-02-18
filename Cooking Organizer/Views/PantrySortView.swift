//
//  PantrySortView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/01/2023.
//  Copyright © 2023 Rares Soponar. All rights reserved.
//

import UIKit

enum PantrySortOption {
    case name
    case expirationDate
}

class PantrySortView: UIView {
    
    // MARK: - Checkboxes
    
    @IBOutlet var checkboxes: [Checkbox]!
    
    @IBOutlet weak var nameCheckbox: Checkbox!
    @IBOutlet weak var expirationDateCheckbox: Checkbox!
    
    // MARK: - Options Views
    
    @IBOutlet weak var nameOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNameOptionTap(sender:)))
            self.nameOptionView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet weak var expirationDateOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleExpirationDateOptionTap(sender:)))
            self.expirationDateOptionView.addGestureRecognizer(tapGesture)
        }
    }
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var ascendingDescendingSegmentedControl: UISegmentedControl! {
        didSet {
            if let font = UIFont(name: "Proxima Nova Alt Bold", size: 14.0) {
                self.ascendingDescendingSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: UIColor.hexStringToUIColor(hex: "#A16702")],
                                                                                for: .normal)
            }
        }
    }
    @IBOutlet weak var sortOptionsStackView: UIStackView!
    
    var selectedSortOption: PantrySortOption? {
        didSet {
            self.nameCheckbox.isChecked = self.selectedSortOption == .some(.name)
            self.expirationDateCheckbox.isChecked = self.selectedSortOption == .some(.expirationDate)
        }
    }
    
    // MARK: - View Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    // MARK: - Private helpers
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PantrySortView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        self.contentView.layer.cornerRadius = 8.0
        
        self.checkboxes.forEach { checkbox in
            self.checkboxSetup(withCheckbox: checkbox)
        }
    }
    
    private func checkboxSetup(withCheckbox checkbox: Checkbox) {
        checkbox.checkmarkColor = UIColor.checkbockColor()
        checkbox.checkedBorderColor = UIColor.checkbockColor()
        checkbox.uncheckedBorderColor = UIColor.checkbockColor()
        checkbox.checkmarkStyle = .circle
        checkbox.borderStyle = .circle
    }
    
    // MARK: - Actions
    
    @IBAction func nameCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.nameCheckbox.isChecked ? .name : nil
    }
    
    @IBAction func expirationDateCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.expirationDateCheckbox.isChecked ? .expirationDate : nil
    }
    
    func resetCheckboxes(withoutSelectedCheckbox selectedCheckbox: Checkbox) {
        self.checkboxes.forEach { checkbox in
            if checkbox != selectedCheckbox {
                checkbox.isChecked = false
            }
        }
    }
    
    // MARK: - Selectors for handling gesture recognizers
    
    @objc func handleNameOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.nameCheckbox)
        
        self.nameCheckbox.isChecked = !self.nameCheckbox.isChecked
        
        self.selectedSortOption = self.nameCheckbox.isChecked ? .name : nil
    }
    
    @objc func handleExpirationDateOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.expirationDateCheckbox)
        
        self.expirationDateCheckbox.isChecked = !self.expirationDateCheckbox.isChecked
        
        self.selectedSortOption = self.expirationDateCheckbox.isChecked ? .expirationDate : nil
    }
    
}
