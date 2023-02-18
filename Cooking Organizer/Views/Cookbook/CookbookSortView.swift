//
//  CookbookSortView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 16/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum SortStackViewButtons: String, CaseIterable {
    /// Home Ingredients
    case nameAscending = "Name Ascending"
    case nameDescending = "Name Descending"
    case expirationDateAscending = "Expiration Date Ascending"
    case expirationDateDescending = "Expiration Date Descending"
}

enum SortOption {
    case name
    case cookingTime
    case dificulty
    case portions
    case lastCooking
}

class CookbookSortView: UIView {
    @IBOutlet var checkboxes: [Checkbox]!
    
    @IBOutlet weak var nameCheckbox: Checkbox! {
        didSet {
            self.nameCheckbox.checkmarkColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.nameCheckbox.checkedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.nameCheckbox.uncheckedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
        }
    }
    @IBOutlet weak var cookingTimeCheckbox: Checkbox! {
        didSet {
            self.cookingTimeCheckbox.checkmarkColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.cookingTimeCheckbox.checkedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.cookingTimeCheckbox.uncheckedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
        }
    }
    @IBOutlet weak var dificultyCheckbox: Checkbox! {
        didSet {
            self.dificultyCheckbox.checkmarkColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.dificultyCheckbox.checkedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.dificultyCheckbox.uncheckedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
        }
    }
    @IBOutlet weak var portionsCheckbox: Checkbox! {
        didSet {
            self.portionsCheckbox.checkmarkColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.portionsCheckbox.checkedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.portionsCheckbox.uncheckedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
        }
    }
    @IBOutlet weak var lastCookingCheckbox: Checkbox! {
        didSet {
            self.lastCookingCheckbox.checkmarkColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.lastCookingCheckbox.checkedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
            self.lastCookingCheckbox.uncheckedBorderColor = UIColor.hexStringToUIColor(hex: "#A16702")
        }
    }
    
    @IBOutlet weak var nameOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleNameOptionTap(sender:)))
            self.nameOptionView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var cookingTimeOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCookingTimeOptionTap(sender:)))
            self.cookingTimeOptionView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var dificultyOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDificultyOptionTap(sender:)))
            self.dificultyOptionView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var portionsOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePortionsOptionTap(sender:)))
            self.portionsOptionView.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var lastCookingOptionView: UIView! {
        didSet {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLastCookingOptionTap(sender:)))
            self.lastCookingOptionView.addGestureRecognizer(tapGesture)
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
    
    var selectedSortOption: SortOption? {
        didSet {
            self.nameCheckbox.isChecked = self.selectedSortOption == .some(.name)
            self.cookingTimeCheckbox.isChecked = self.selectedSortOption == .some(.cookingTime)
            self.dificultyCheckbox.isChecked = self.selectedSortOption == .some(.dificulty)
            self.portionsCheckbox.isChecked = self.selectedSortOption == .some(.portions)
            self.lastCookingCheckbox.isChecked = self.selectedSortOption == .some(.lastCooking)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CookbookSortView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        self.contentView.layer.cornerRadius = 8.0
        
        self.checkboxes.forEach { checkbox in
            checkbox.checkmarkStyle = .circle
            checkbox.borderStyle = .circle
        }
    }
    
    @IBAction func nameCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.nameCheckbox.isChecked ? .name : nil
    }
    
    @IBAction func cookingTimeCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.cookingTimeCheckbox.isChecked ? .cookingTime : nil
    }
    
    @IBAction func dificultyCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.dificultyCheckbox.isChecked ? .dificulty : nil
    }
    
    @IBAction func portionsCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.portionsCheckbox.isChecked ? .portions : nil
    }
    
    @IBAction func lastCookingCheckboxSelected(_ sender: Any) {
        if let checkbox = sender as? Checkbox {
            self.resetCheckboxes(withoutSelectedCheckbox: checkbox)
        }
        
        self.selectedSortOption = self.lastCookingCheckbox.isChecked ? .lastCooking : nil
    }
    
    func resetCheckboxes(withoutSelectedCheckbox selectedCheckbox: Checkbox) {
        self.checkboxes.forEach { checkbox in
            if checkbox != selectedCheckbox {
                checkbox.isChecked = false
            }
        }
    }
    
    @objc func handleNameOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.nameCheckbox)
        
        self.nameCheckbox.isChecked = !self.nameCheckbox.isChecked
        
        self.selectedSortOption = self.nameCheckbox.isChecked ? .name : nil
    }
    
    @objc func handleCookingTimeOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.cookingTimeCheckbox)
        
        self.cookingTimeCheckbox.isChecked = !self.cookingTimeCheckbox.isChecked
        
        self.selectedSortOption = self.cookingTimeCheckbox.isChecked ? .cookingTime : nil
    }
    
    @objc func handlePortionsOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.portionsCheckbox)
        
        self.portionsCheckbox.isChecked = !self.portionsCheckbox.isChecked
        
        self.selectedSortOption = self.portionsCheckbox.isChecked ? .portions : nil
    }
    
    @objc func handleDificultyOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.dificultyCheckbox)
        
        self.dificultyCheckbox.isChecked = !self.dificultyCheckbox.isChecked
        
        self.selectedSortOption = self.dificultyCheckbox.isChecked ? .dificulty : nil
    }
    
    @objc func handleLastCookingOptionTap(sender: UITapGestureRecognizer) {
        self.resetCheckboxes(withoutSelectedCheckbox: self.lastCookingCheckbox)
        
        self.lastCookingCheckbox.isChecked = !self.lastCookingCheckbox.isChecked
        
        self.selectedSortOption = self.lastCookingCheckbox.isChecked ? .lastCooking : nil
    }
}
