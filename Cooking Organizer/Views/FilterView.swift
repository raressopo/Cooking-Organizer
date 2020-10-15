//
//  FilterView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 14/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

// MARK: - Filter View Protocol

protocol FilterViewDelegate: class {
    func homeIngredientFilterPressed(withParams params: HomeIngredientsFilterParams)
    func homeIngredientResetFilterPressed()
    
    func recipeFilterPressed(withParams params: RecipeFilterParams)
    func recipeResetFilterPressed()
}

extension FilterViewDelegate {
    func homeIngredientFilterPressed(withParams params: HomeIngredientsFilterParams) {}
    func homeIngredientResetFilterPressed() {}
    
    func recipeFilterPressed(withParams params: RecipeFilterParams) {}
    func recipeResetFilterPressed() {}
}

// MARK: - Filter Criteria enum

enum FilterCriteria {
    case Category
    case Availability
    
    case RecipeCategory
    case CookingTime
    case Difficulty
    case Portions
    case CookingDate
}

enum LastDateCriteriaStrings: String {
    case Never = "Never"
    case OneWeek = "1 Week Old"
    case TwoWeeks = "2 Weeks Old"
    case OneMonthPlus = "1 Month +"
}

enum DifficultyCriteriaStrings: String {
    case Easy = "Easy"
    case Medium = "Medium"
    case Hard = "Hard"
}

enum CookingTimeCriteriaStrings: String {
    case under15Min = "< 15 Min"
    case between16And30Mins = "16-30 Mins"
    case between31And60Mins = "31-60 Mins"
    case oneHourPlus = "1H+"
}

enum PortionsCriteriaStrings: String {
    case oneOrTwo = "1-2"
    case threeOrFour = "3-4"
    case betweenFiveAndEight = "5-8"
    case ninePlus = "9+"
}

// MARK: - Helper Structs - Filter Params

struct HomeIngredientsFilterParams {
    var name: String?
    var expired: Bool
    var available: Bool
}

struct RecipeFilterParams {
    var categoryString: String?
    var cookingTime: CookingTimeCriteriaStrings?
    var difficulty: DifficultyCriteriaStrings?
    var portions: PortionsCriteriaStrings?
    var cookingDate: LastDateCriteriaStrings?
}

// MARK: - Base Filter View

class FilterView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var criteriaStackView: UIStackView!
    
    @IBOutlet weak var resetFilterButton: UIButton!
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var criteriaStackViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: FilterViewDelegate?
    
    static let defaultCGRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    
    init(withCriterias criterias: [FilterCriteria], filterParams params: HomeIngredientsFilterParams?, andFrame frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("FilterView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
}

// MARK: - Home Ingredients Filter View

class HomeIngredientsFilterView: FilterView {
    var filterParams = HomeIngredientsFilterParams(name: nil, expired: false, available: false)
    
    var categoryButton = UIButton()
    
    var expiredButton = UIButton()
    var availableButton = UIButton()
    
    override init(withCriterias criterias: [FilterCriteria], filterParams params: HomeIngredientsFilterParams?, andFrame frame: CGRect) {
        super.init(withCriterias: criterias, filterParams: params, andFrame: frame)
        
        if let params = params {
            filterParams = params
        }
        
        setupView(withCriterias: criterias)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView(withCriterias criterias: [FilterCriteria]) {
        filterButton.addTarget(self, action: #selector(filterPressed), for: .touchUpInside)
        resetFilterButton.addTarget(self, action: #selector(resetFilterPressed), for: .touchUpInside)
        
        for criteria in criterias {
            switch criteria {
            case .Category:
                setupCategoryButton()
                
                break
            case .Availability:
                let availabilityButtonsStackView = UIStackView()
                
                availabilityButtonsStackView.distribution = .fillEqually
                availabilityButtonsStackView.axis = .horizontal
                
                availableButton.setTitle("Available", for: .normal)
                
                if filterParams.available {
                    availableButton.backgroundColor = .systemBlue
                    availableButton.setTitleColor(.white, for: .normal)
                } else {
                    availableButton.setTitleColor(.systemBlue, for: .normal)
                }
                
                availableButton.addTarget(self, action: #selector(availablePressed), for: .touchUpInside)
                
                availabilityButtonsStackView.addArrangedSubview(availableButton)
                
                expiredButton.setTitle("Expired", for: .normal)
                
                if filterParams.expired {
                    expiredButton.backgroundColor = .systemBlue
                    expiredButton.setTitleColor(.white, for: .normal)
                } else {
                    expiredButton.setTitleColor(.systemBlue, for: .normal)
                }
                
                expiredButton.addTarget(self, action: #selector(expiredPressed), for: .touchUpInside)
                
                availabilityButtonsStackView.addArrangedSubview(expiredButton)
                
                criteriaStackView.addArrangedSubview(availabilityButtonsStackView)
                
                break
                
            default:
                break
            }
        }
        
        criteriaStackViewHeightConstraint.constant = CGFloat(criterias.count) * 80
    }
    
    private func setupCategoryButton() {
        categoryButton.setTitle(filterParams.name ?? "Category", for: .normal)
        categoryButton.setTitleColor(.systemBlue, for: .normal)
        categoryButton.addTarget(self, action: #selector(categoriesPressed), for: .touchUpInside)
        
        criteriaStackView.addArrangedSubview(categoryButton)
    }
    
    // MARK: - Selectors
    
    @objc
    private func categoriesPressed() {
        let categoriesView = HomeIngredientsCategoriesView()

        categoriesView.selectedCategoryName = filterParams.name
        categoriesView.delegate = self
        
        addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)])
    }
    
    @objc
    private func filterPressed() {
        delegate?.homeIngredientFilterPressed(withParams: filterParams)
        
        removeFromSuperview()
    }
    
    @objc
    private func resetFilterPressed() {
        delegate?.homeIngredientResetFilterPressed()
        
        removeFromSuperview()
    }
    
    @objc
    private func expiredPressed() {
        filterParams.expired = true
        filterParams.available = false
        
        expiredButton.backgroundColor = .systemBlue
        expiredButton.setTitleColor(.white, for: .normal)
        
        availableButton.backgroundColor = .white
        availableButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    @objc
    private func availablePressed() {
        filterParams.expired = false
        filterParams.available = true
        
        availableButton.backgroundColor = .systemBlue
        availableButton.setTitleColor(.white, for: .normal)
        
        expiredButton.backgroundColor = .white
        expiredButton.setTitleColor(.systemBlue, for: .normal)
    }
}

extension HomeIngredientsFilterView: CategoriesViewDelegate {
    func didSelectHICategory(withCategoryName name: String) {
        filterParams.name = name
        
        categoryButton.setTitle(name, for: .normal)
    }
}

// MARK: - Recipes Filter View

class RecipesFilterView: FilterView {
    var filterParams = RecipeFilterParams(categoryString: nil, cookingTime: nil, difficulty: nil, portions: nil, cookingDate: nil)
    
    var categoryButton = UIButton()
    
    let cookingDatesStackView = CookingDateFilterParamsStackView(frame: defaultCGRect)
    let difficultyStackView = DifficultyCriteriaStackView(frame: defaultCGRect)
    let cookingTimeStackView = CookingTimeCriteriaStackView(frame: defaultCGRect)
    let portionsStackView = PortionsCriteriaStackView(frame: defaultCGRect)
    
    init(withParams params: RecipeFilterParams?, criterias: [FilterCriteria], andFrame frame: CGRect) {
        super.init(withCriterias: criterias, filterParams: nil, andFrame: frame)
        
        if let params = params {
            filterParams = params
        }
        
        setupViews(withCriterias: criterias)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(withCriterias criterias: [FilterCriteria]) {
        filterButton.addTarget(self, action: #selector(filterPressed), for: .touchUpInside)
        resetFilterButton.addTarget(self, action: #selector(resetFilterPressed), for: .touchUpInside)
        
        for criteria in criterias {
            switch criteria {
            case .RecipeCategory:
                addCriteriaTitleLabel(withTitle: "Category")
                
                categoryButton.setTitle(filterParams.categoryString ?? "Category", for: .normal)
                categoryButton.setTitleColor(.systemBlue, for: .normal)
                categoryButton.addTarget(self, action: #selector(categoriesPressed), for: .touchUpInside)
                
                criteriaStackView.addArrangedSubview(categoryButton)
            case .CookingDate:
                addCriteriaTitleLabel(withTitle: "Last Cooking Date")
                
                cookingDatesStackView.selectedLastCookingDateTime = filterParams.cookingDate
                
                criteriaStackView.addArrangedSubview(cookingDatesStackView)
            case .Difficulty:
                addCriteriaTitleLabel(withTitle: "Difficulty")
                
                difficultyStackView.selectedDifficulty = filterParams.difficulty
                
                criteriaStackView.addArrangedSubview(difficultyStackView)
            case .CookingTime:
                addCriteriaTitleLabel(withTitle: "Cooking Time")
                
                cookingTimeStackView.selectedCookingTime = filterParams.cookingTime
                
                criteriaStackView.addArrangedSubview(cookingTimeStackView)
            case .Portions:
                addCriteriaTitleLabel(withTitle: "Portions")
                
                portionsStackView.selectedPortions = filterParams.portions
                
                criteriaStackView.addArrangedSubview(portionsStackView)
            default:
                break
            }
        }
        
        criteriaStackViewHeightConstraint.constant = CGFloat(criterias.count) * 90
    }
    
    private func addCriteriaTitleLabel(withTitle title: String) {
        let criteriaTitle = UILabel()
        
        criteriaTitle.text = title
        criteriaTitle.textAlignment = .center
        criteriaTitle.backgroundColor = .systemGray4
        
        criteriaStackView.addArrangedSubview(criteriaTitle)
    }
    
    @objc
    private func categoriesPressed() {
        let categoriesView = RecipeCategoriesView()

        categoriesView.isRecipeCategorySelection = true
        categoriesView.selectedRecipeCategory = filterParams.categoryString
        categoriesView.delegate = self
        
        addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)])
    }
    
    @objc
    private func filterPressed() {
        filterParams.cookingDate = cookingDatesStackView.selectedLastCookingDateTime
        filterParams.portions = portionsStackView.selectedPortions
        filterParams.difficulty = difficultyStackView.selectedDifficulty
        filterParams.cookingTime = cookingTimeStackView.selectedCookingTime
        
        delegate?.recipeFilterPressed(withParams: filterParams)
        
        removeFromSuperview()
    }
    
    @objc
    private func resetFilterPressed() {
        delegate?.recipeResetFilterPressed()
        
        removeFromSuperview()
    }
}

extension RecipesFilterView: CategoriesViewDelegate {
    func didSelectRecipeCategory(withCategoryName name: String) {
        filterParams.categoryString = name
        
        categoryButton.setTitle(name, for: .normal)
    }
}

// MARK: - Filter Criteria StackView Base

class FilterCriteriaStackView: UIStackView {
    var buttons = [UIButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        distribution = .fillEqually
        axis = .horizontal
    }
    
    func setupButton(button: UIButton, withTitle title: String, andSelector selector: Selector) {
        button.titleLabel?.numberOfLines = 3
        button.titleLabel?.textAlignment = .center
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        addArrangedSubview(button)
    }
    
    final func configureButtonsAfterSelection(withSelectedButton selectedButton: UIButton) {
        for button in buttons {
            if selectedButton == button {
                selectedButton.backgroundColor = .systemBlue
                selectedButton.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.systemBlue, for: .normal)
            }
        }
    }
}

// MARK: - Cooking Date Filter Params StackView

class CookingDateFilterParamsStackView: FilterCriteriaStackView {
    let neverButton = UIButton()
    let oneWeekOldButton = UIButton()
    let twoWeeksOldButton = UIButton()
    let oneMonthPlusButton = UIButton()
    
    var selectedLastCookingDateTime: LastDateCriteriaStrings? {
        didSet {
            switch selectedLastCookingDateTime {
            case .Never:
                configureButtonsAfterSelection(withSelectedButton: neverButton)
                
                break
            case .OneWeek:
                configureButtonsAfterSelection(withSelectedButton: oneWeekOldButton)
                
                break
            case .TwoWeeks:
                configureButtonsAfterSelection(withSelectedButton: twoWeeksOldButton)
                
                break
            case .OneMonthPlus:
                configureButtonsAfterSelection(withSelectedButton: oneMonthPlusButton)
                
                break
            case .none:
                break
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        buttons = [neverButton, oneWeekOldButton, twoWeeksOldButton, oneMonthPlusButton]
        
        setupAllButtons()
    }
    
    private func setupAllButtons() {
        setupButton(button: neverButton, withTitle: LastDateCriteriaStrings.Never.rawValue, andSelector: #selector(neverButtonPressed))
        setupButton(button: oneWeekOldButton, withTitle: LastDateCriteriaStrings.OneWeek.rawValue, andSelector: #selector(oneWeekOldPressed))
        setupButton(button: twoWeeksOldButton, withTitle: LastDateCriteriaStrings.TwoWeeks.rawValue, andSelector: #selector(twoWeeksOldPressed))
        setupButton(button: oneMonthPlusButton, withTitle: LastDateCriteriaStrings.OneMonthPlus.rawValue, andSelector: #selector(oneMonthPlusPressed))
    }
    
    // MARK: - Private Selectors
    
    @objc
    private func neverButtonPressed() {
        selectedLastCookingDateTime = .Never
    }
    
    @objc
    private func oneWeekOldPressed() {
        selectedLastCookingDateTime = .OneWeek
    }
    
    @objc
    private func twoWeeksOldPressed() {
        selectedLastCookingDateTime = .TwoWeeks
    }
    
    @objc
    private func oneMonthPlusPressed() {
        selectedLastCookingDateTime = .OneMonthPlus
    }
}

// MARK: - Difficulty Criteria StackView

class DifficultyCriteriaStackView: FilterCriteriaStackView {
    let easyButton = UIButton()
    let mediumButton = UIButton()
    let hardButton = UIButton()
    
    var selectedDifficulty: DifficultyCriteriaStrings? {
        didSet {
            switch selectedDifficulty {
            case .Easy:
                configureButtonsAfterSelection(withSelectedButton: easyButton)
                
                break
            case .Medium:
                configureButtonsAfterSelection(withSelectedButton: mediumButton)
                
                break
            case .Hard:
                configureButtonsAfterSelection(withSelectedButton: hardButton)
                
                break
            case .none:
                break
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        buttons = [easyButton, mediumButton, hardButton]
        
        setupAllButtons()
    }
    
    private func setupAllButtons() {
        setupButton(button: easyButton, withTitle: DifficultyCriteriaStrings.Easy.rawValue, andSelector: #selector(easyPressed))
        setupButton(button: mediumButton, withTitle: DifficultyCriteriaStrings.Medium.rawValue, andSelector: #selector(mediumPressed))
        setupButton(button: hardButton, withTitle: DifficultyCriteriaStrings.Hard.rawValue, andSelector: #selector(hardPressed))
    }
    
    @objc
    private func easyPressed() {
        configureButtonsAfterSelection(withSelectedButton: easyButton)
        
        selectedDifficulty = .Easy
    }
    
    @objc
    private func mediumPressed() {
        configureButtonsAfterSelection(withSelectedButton: mediumButton)
        
        selectedDifficulty = .Medium
    }
    
    @objc
    private func hardPressed() {
        configureButtonsAfterSelection(withSelectedButton: hardButton)
        
        selectedDifficulty = .Hard
    }
}

// MARK: - Cooking Time Criteria StackView

class CookingTimeCriteriaStackView: FilterCriteriaStackView {
    let under15MinsButton = UIButton()
    let between16And30MinsButton = UIButton()
    let between31And60MinsButton = UIButton()
    let oneHourPlusButton = UIButton()
    
    var selectedCookingTime: CookingTimeCriteriaStrings? {
        didSet {
            switch selectedCookingTime {
            case .under15Min:
                configureButtonsAfterSelection(withSelectedButton: under15MinsButton)
                
                break
            case .between16And30Mins:
                configureButtonsAfterSelection(withSelectedButton: between16And30MinsButton)
                
                break
            case .between31And60Mins:
                configureButtonsAfterSelection(withSelectedButton: between31And60MinsButton)
                
                break
            case .oneHourPlus:
                configureButtonsAfterSelection(withSelectedButton: oneHourPlusButton)
                
                break
            case .none:
                break
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        buttons = [under15MinsButton, between16And30MinsButton, between31And60MinsButton, oneHourPlusButton]
        
        setupAllButtons()
    }
    
    private func setupAllButtons() {
        setupButton(button: under15MinsButton, withTitle: CookingTimeCriteriaStrings.under15Min.rawValue, andSelector: #selector(under15MinsPressed))
        setupButton(button: between16And30MinsButton, withTitle: CookingTimeCriteriaStrings.between16And30Mins.rawValue, andSelector: #selector(between16And30MinsPressed))
        setupButton(button: between31And60MinsButton, withTitle: CookingTimeCriteriaStrings.between31And60Mins.rawValue, andSelector: #selector(between31And60MinsPressed))
        setupButton(button: oneHourPlusButton, withTitle: CookingTimeCriteriaStrings.oneHourPlus.rawValue, andSelector: #selector(oneHourPlusPressed))
    }
    
    @objc
    private func under15MinsPressed() {
        configureButtonsAfterSelection(withSelectedButton: under15MinsButton)
        
        selectedCookingTime = .under15Min
    }
    
    @objc
    private func between16And30MinsPressed() {
        configureButtonsAfterSelection(withSelectedButton: between16And30MinsButton)
        
        selectedCookingTime = .between16And30Mins
    }
    
    @objc
    private func between31And60MinsPressed() {
        configureButtonsAfterSelection(withSelectedButton: between31And60MinsButton)
        
        selectedCookingTime = .between31And60Mins
    }
    
    @objc
    private func oneHourPlusPressed() {
        configureButtonsAfterSelection(withSelectedButton: oneHourPlusButton)
        
        selectedCookingTime = .oneHourPlus
    }
}

// MARK: - Portions Criteria StackView

class PortionsCriteriaStackView: FilterCriteriaStackView {
    let oneOrTwoButton = UIButton()
    let threeOrFourButton = UIButton()
    let betweenFiveAndEightButton = UIButton()
    let ninePlusButton = UIButton()
    
    var selectedPortions: PortionsCriteriaStrings? {
        didSet {
            switch selectedPortions {
            case .oneOrTwo:
                configureButtonsAfterSelection(withSelectedButton: oneOrTwoButton)
                
                break
            case .threeOrFour:
                configureButtonsAfterSelection(withSelectedButton: threeOrFourButton)
                
                break
            case .betweenFiveAndEight:
                configureButtonsAfterSelection(withSelectedButton: betweenFiveAndEightButton)
                
                break
            case .ninePlus:
                configureButtonsAfterSelection(withSelectedButton: ninePlusButton)
                
                break
            case .none:
                break
            }
        }
    }
    
    override func commonInit() {
        super.commonInit()
        
        buttons = [oneOrTwoButton, threeOrFourButton, betweenFiveAndEightButton, ninePlusButton]
        
        setupAllButtons()
    }
    
    private func setupAllButtons() {
        setupButton(button: oneOrTwoButton, withTitle: PortionsCriteriaStrings.oneOrTwo.rawValue, andSelector: #selector(oneOrTwoPressed))
        setupButton(button: threeOrFourButton, withTitle: PortionsCriteriaStrings.threeOrFour.rawValue, andSelector: #selector(threeOrFourPressed))
        setupButton(button: betweenFiveAndEightButton, withTitle: PortionsCriteriaStrings.betweenFiveAndEight.rawValue, andSelector: #selector(betweenFiveAndEightPressed))
        setupButton(button: ninePlusButton, withTitle: PortionsCriteriaStrings.ninePlus.rawValue, andSelector: #selector(ninePlusPressed))
    }
    
    @objc
    private func oneOrTwoPressed() {
        configureButtonsAfterSelection(withSelectedButton: oneOrTwoButton)
        
        selectedPortions = .oneOrTwo
    }
    
    @objc
    private func threeOrFourPressed() {
        configureButtonsAfterSelection(withSelectedButton: threeOrFourButton)
        
        selectedPortions = .threeOrFour
    }
    
    @objc
    private func betweenFiveAndEightPressed() {
        configureButtonsAfterSelection(withSelectedButton: betweenFiveAndEightButton)
        
        selectedPortions = .betweenFiveAndEight
    }
    
    @objc
    private func ninePlusPressed() {
        configureButtonsAfterSelection(withSelectedButton: ninePlusButton)
        
        selectedPortions = .ninePlus
    }
}
