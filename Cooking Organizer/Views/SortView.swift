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
    case NameAscending = "Name Ascending"
    case NameDescending = "Name Descending"
    case ExpirationDateAscending = "Expiration Date Ascending"
    case ExpirationDateDescending = "Expiration Date Descending"
    
    /// Recipes
    case RecipeNameAscending = "Recipe Name Ascending"
    case RecipeNameDescending = "Recipe Name Descending"
    case CookingTimeAscending = "Cooking Time Ascending"
    case CookingTimeDescending = "Cooking Time Descending"
    case DifficultyAscending = "Difficulty Ascending"
    case DifficultyDescending = "Difficulty Descending"
    case PortionsAscending = "Portions Ascending"
    case PortionsDescending = "Portions Descending"
    case LastCookingDateAscending = "Last Cooking Date Ascending"
    case LastCookingDateDescending = "Last Cooking Date Descending"
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
            case .NameAscending:
                button.addTarget(self, action: #selector(nameAscendingPressed), for: .touchUpInside)
            case .NameDescending:
                button.addTarget(self, action: #selector(nameDescendingPressed), for: .touchUpInside)
            case .ExpirationDateAscending:
                button.addTarget(self, action: #selector(expirationDateAscendingPressed), for: .touchUpInside)
            case .ExpirationDateDescending:
                button.addTarget(self, action: #selector(expirationDateDescendingPressed), for: .touchUpInside)
                
            /// Recipes
            case .RecipeNameAscending:
                button.addTarget(self, action: #selector(recipeNameAscendingPressed), for: .touchUpInside)
            case .RecipeNameDescending:
                button.addTarget(self, action: #selector(recipeNameDescendingPressed), for: .touchUpInside)
            case .CookingTimeAscending:
                button.addTarget(self, action: #selector(cookingTimeAscendingPressed), for: .touchUpInside)
            case .CookingTimeDescending:
                button.addTarget(self, action: #selector(cookingTimeDescendingPressed), for: .touchUpInside)
            case .DifficultyAscending:
                button.addTarget(self, action: #selector(difficultyAscendingPressed), for: .touchUpInside)
            case .DifficultyDescending:
                button.addTarget(self, action: #selector(difficultyDescendingPressed), for: .touchUpInside)
            case .PortionsAscending:
                button.addTarget(self, action: #selector(portionAscendingPressed), for: .touchUpInside)
            case .PortionsDescending:
                button.addTarget(self, action: #selector(portionDescendingPressed), for: .touchUpInside)
            case .LastCookingDateAscending:
                button.addTarget(self, action: #selector(lastCookingDateAscendingPressed), for: .touchUpInside)
            case .LastCookingDateDescending:
                button.addTarget(self, action: #selector(lastCookingDateDescendingPressed), for: .touchUpInside)
            }
            
            sortOptionsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Private Selectors
    
    /// Home Ingredients
    @objc
    private func nameAscendingPressed() {
        self.selectedSortOption?(.NameAscending)
    }
    
    @objc
    private func nameDescendingPressed() {
        self.selectedSortOption?(.NameDescending)
    }
    
    @objc
    private func expirationDateAscendingPressed() {
        self.selectedSortOption?(.ExpirationDateAscending)
    }
    
    @objc
    private func expirationDateDescendingPressed() {
        self.selectedSortOption?(.ExpirationDateDescending)
    }
    
    /// Recipes
    @objc
    private func recipeNameAscendingPressed() {
        self.selectedSortOption?(.RecipeNameAscending)
    }
    
    @objc
    private func recipeNameDescendingPressed() {
        self.selectedSortOption?(.RecipeNameDescending)
    }
    
    @objc
    private func cookingTimeAscendingPressed() {
        self.selectedSortOption?(.CookingTimeAscending)
    }
    
    @objc
    private func cookingTimeDescendingPressed() {
        self.selectedSortOption?(.CookingTimeDescending)
    }
    
    @objc
    private func difficultyAscendingPressed() {
        self.selectedSortOption?(.DifficultyAscending)
    }
    
    @objc
    private func difficultyDescendingPressed() {
        self.selectedSortOption?(.DifficultyDescending)
    }
    
    @objc
    private func portionAscendingPressed() {
        self.selectedSortOption?(.PortionsAscending)
    }
    
    @objc
    private func portionDescendingPressed() {
        self.selectedSortOption?(.PortionsDescending)
    }
    
    @objc
    private func lastCookingDateAscendingPressed() {
        self.selectedSortOption?(.LastCookingDateAscending)
    }
    
    @objc
    private func lastCookingDateDescendingPressed() {
        self.selectedSortOption?(.LastCookingDateDescending)
    }
}
