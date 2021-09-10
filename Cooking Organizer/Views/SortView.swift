//
//  SortView.swift
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
    
    /// Recipes
    case recipeNameAscending = "Recipe Name Ascending"
    case recipeNameDescending = "Recipe Name Descending"
    case cookingTimeAscending = "Cooking Time Ascending"
    case cookingTimeDescending = "Cooking Time Descending"
    case difficultyAscending = "Difficulty Ascending"
    case difficultyDescending = "Difficulty Descending"
    case portionsAscending = "Portions Ascending"
    case portionsDescending = "Portions Descending"
    case lastCookingDateAscending = "Last Cooking Date Ascending"
    case lastCookingDateDescending = "Last Cooking Date Descending"
}

protocol SortViewDelegate: AnyObject {
    func didSelect(sortOption option: SortStackViewButtons)
}

class SortView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var sortOptionsStackView: UIStackView!
    
    var selectedSortOption: ((SortStackViewButtons) -> Void)?
    var sortOption: SortStackViewButtons?
    
    weak var delegate: SortViewDelegate?
    
    init(withButtons buttons: [SortStackViewButtons], andFrame frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100)) {
        super.init(frame: frame)
        
        commonInit(withButtons: buttons)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit(withButtons buttons: [SortStackViewButtons]) {
        Bundle.main.loadNibNamed("SortView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        configureStackView(withButtons: buttons)
    }
    
    private func configureStackView(withButtons buttons: [SortStackViewButtons]) {
        sortOptionsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([sortOptionsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
                                     sortOptionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                                     sortOptionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     sortOptionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)])
        
        for sortButton in buttons {
            let button = UIButton()
            
            button.setTitle(sortButton.rawValue, for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            
            switch sortButton {
            /// Home Ingredients
            case .nameAscending:
                button.addTarget(self, action: #selector(nameAscendingPressed), for: .touchUpInside)
            case .nameDescending:
                button.addTarget(self, action: #selector(nameDescendingPressed), for: .touchUpInside)
            case .expirationDateAscending:
                button.addTarget(self, action: #selector(expirationDateAscendingPressed), for: .touchUpInside)
            case .expirationDateDescending:
                button.addTarget(self, action: #selector(expirationDateDescendingPressed), for: .touchUpInside)
                
            /// Recipes
            case .recipeNameAscending:
                button.addTarget(self, action: #selector(recipeNameAscendingPressed), for: .touchUpInside)
            case .recipeNameDescending:
                button.addTarget(self, action: #selector(recipeNameDescendingPressed), for: .touchUpInside)
            case .cookingTimeAscending:
                button.addTarget(self, action: #selector(cookingTimeAscendingPressed), for: .touchUpInside)
            case .cookingTimeDescending:
                button.addTarget(self, action: #selector(cookingTimeDescendingPressed), for: .touchUpInside)
            case .difficultyAscending:
                button.addTarget(self, action: #selector(difficultyAscendingPressed), for: .touchUpInside)
            case .difficultyDescending:
                button.addTarget(self, action: #selector(difficultyDescendingPressed), for: .touchUpInside)
            case .portionsAscending:
                button.addTarget(self, action: #selector(portionAscendingPressed), for: .touchUpInside)
            case .portionsDescending:
                button.addTarget(self, action: #selector(portionDescendingPressed), for: .touchUpInside)
            case .lastCookingDateAscending:
                button.addTarget(self, action: #selector(lastCookingDateAscendingPressed), for: .touchUpInside)
            case .lastCookingDateDescending:
                button.addTarget(self, action: #selector(lastCookingDateDescendingPressed), for: .touchUpInside)
            }
            
            sortOptionsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Private Selectors
    
    /// Home Ingredients
    @objc
    private func nameAscendingPressed() {
        self.selectedSortOption?(.nameAscending)
    }
    
    @objc
    private func nameDescendingPressed() {
        self.selectedSortOption?(.nameDescending)
    }
    
    @objc
    private func expirationDateAscendingPressed() {
        self.selectedSortOption?(.expirationDateAscending)
    }
    
    @objc
    private func expirationDateDescendingPressed() {
        self.selectedSortOption?(.expirationDateDescending)
    }
    
    /// Recipes
    @objc
    private func recipeNameAscendingPressed() {
        self.selectedSortOption?(.recipeNameAscending)
    }
    
    @objc
    private func recipeNameDescendingPressed() {
        self.selectedSortOption?(.recipeNameDescending)
    }
    
    @objc
    private func cookingTimeAscendingPressed() {
        self.selectedSortOption?(.cookingTimeAscending)
    }
    
    @objc
    private func cookingTimeDescendingPressed() {
        self.selectedSortOption?(.cookingTimeDescending)
    }
    
    @objc
    private func difficultyAscendingPressed() {
        self.selectedSortOption?(.difficultyAscending)
    }
    
    @objc
    private func difficultyDescendingPressed() {
        self.selectedSortOption?(.difficultyDescending)
    }
    
    @objc
    private func portionAscendingPressed() {
        self.selectedSortOption?(.portionsAscending)
    }
    
    @objc
    private func portionDescendingPressed() {
        self.selectedSortOption?(.portionsDescending)
    }
    
    @objc
    private func lastCookingDateAscendingPressed() {
        self.selectedSortOption?(.lastCookingDateAscending)
    }
    
    @objc
    private func lastCookingDateDescendingPressed() {
        self.selectedSortOption?(.lastCookingDateDescending)
    }
}
