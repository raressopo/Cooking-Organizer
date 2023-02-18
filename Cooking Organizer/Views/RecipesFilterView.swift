//
//  RecipesFilterView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 14/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol RecipesFilterViewDelegate: AnyObject {
    func recipeFilterCanceled()
}

extension RecipesFilterViewDelegate {
    func recipeFilterCanceled() {}
}

enum LastDateCriteriaStrings: String {
    case never = "Never"
    case oneWeek = "1 Week Old"
    case twoWeeks = "2 Weeks Old"
    case oneMonthPlus = "1 Month +"
    
    func sliderPosition() -> Float {
        switch self {
        case .never:
            return 1
        case .oneWeek:
            return 2
        case .twoWeeks:
            return 3
        case .oneMonthPlus:
            return 4
        }
    }
}

enum DificultyCriteriaStrings: String {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    func sliderPosition() -> Float {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }
}

enum CookingTimeCriteriaStrings: String {
    case under15Min = "< 15 Min"
    case between16And30Mins = "16-30 Mins"
    case between31And60Mins = "31-60 Mins"
    case oneHourPlus = "1H+"
    
    func sliderPosition() -> Float {
        switch self {
        case .under15Min:
            return 1
        case .between16And30Mins:
            return 2
        case .between31And60Mins:
            return 3
        case .oneHourPlus:
            return 4
        }
    }
}

enum PortionsCriteriaStrings: String {
    case oneOrTwo = "1-2"
    case threeOrFour = "3-4"
    case betweenFiveAndEight = "5-8"
    case ninePlus = "9+"
    
    func sliderPosition() -> Float {
        switch self {
        case .oneOrTwo:
            return 1
        case .threeOrFour:
            return 2
        case .betweenFiveAndEight:
            return 3
        case .ninePlus:
            return 4
        }
    }
}

// MARK: - Helper Structs - Filter Params

struct RecipeFilterParams {
    var categoryString: String?
    var cookingTime: CookingTimeCriteriaStrings?
    var dificulty: DificultyCriteriaStrings?
    var portions: PortionsCriteriaStrings?
    var cookingDate: LastDateCriteriaStrings?
}

class RecipesFilterView: UIView {
    // MARK: - IBOutlets collections
    
    @IBOutlet var criteriaTitles: [UILabel]! {
        didSet {
            self.criteriaTitles.forEach { titleLabel in
                titleLabel.clipsToBounds = true
                titleLabel.layer.cornerRadius = 17.0
                titleLabel.backgroundColor = UIColor.hexStringToUIColor(hex: "#0D4435")
                titleLabel.textColor = UIColor.white
            }
        }
    }
    
    @IBOutlet var categoryContainerViews: [UIView]! {
        didSet {
            self.categoryContainerViews.forEach { containerView in
                containerView.layer.borderWidth = 2.0
                containerView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#0D4435").cgColor
                containerView.clipsToBounds = true
                containerView.layer.cornerRadius = 17.0
            }
        }
    }
    
    // MARK: - Simple IBOutlets
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var selectCategoryButton: UIButton! {
        didSet {
            self.selectCategoryButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    @IBOutlet weak var portionsSlider: UISlider! {
        didSet {
            self.portionsSlider.tintColor = UIColor.buttonTitleColor()
        }
    }
    @IBOutlet weak var cookingTimeSlider: UISlider! {
        didSet {
            self.cookingTimeSlider.tintColor = UIColor.buttonTitleColor()
        }
    }
    @IBOutlet weak var lastCookingSlider: UISlider! {
        didSet {
            self.lastCookingSlider.tintColor = UIColor.buttonTitleColor()
        }
    }
    @IBOutlet weak var dificultySlider: UISlider! {
        didSet {
            self.dificultySlider.tintColor = UIColor.buttonTitleColor()
        }
    }
    
    @IBOutlet weak var cookingTimeSliderValue: UILabel!
    @IBOutlet weak var lastCookingSliderValueLabel: UILabel!
    @IBOutlet weak var portionsValueLabel: UILabel!
    @IBOutlet weak var dificultySliderValueLabel: UILabel!
    
    var filterParams = RecipeFilterParams(categoryString: nil, cookingTime: nil, dificulty: nil, portions: nil, cookingDate: nil)
    
    weak var delegate: RecipesFilterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("RecipesFilterView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        self.cookingTimeSlider.addTarget(self, action: #selector(cookingTimeSliderFinishedSliding), for: .touchUpInside)
        self.lastCookingSlider.addTarget(self, action: #selector(lastCookingSliderFinishedSliding), for: .touchUpInside)
        self.portionsSlider.addTarget(self, action: #selector(portionsSliderFinishedSliding), for: .touchUpInside)
        self.dificultySlider.addTarget(self, action: #selector(dificultySliderFinishedSliding), for: .touchUpInside)
    }
    
    func configure(withFilterParams filterParams: RecipeFilterParams?) {
        if let params = filterParams {
            self.filterParams = params
        }
        
        if let categoryParam = self.filterParams.categoryString {
            self.selectCategoryButton.setTitle(categoryParam, for: .normal)
        } else {
            self.selectCategoryButton.setTitle("Select a category", for: .normal)
        }
        
        if let portionsParam = self.filterParams.portions {
            self.portionsSlider.setValue(portionsParam.sliderPosition(), animated: true)
            self.portionsValueLabel.text = portionsParam.rawValue
        } else {
            self.portionsSlider.setValue(0, animated: true)
            self.portionsValueLabel.text = "No portions option selected"
        }
        
        if let dificultyParam = self.filterParams.dificulty {
            self.dificultySlider.setValue(dificultyParam.sliderPosition(), animated: true)
            self.dificultySliderValueLabel.text = dificultyParam.rawValue
        } else {
            self.dificultySlider.setValue(0, animated: true)
            self.dificultySliderValueLabel.text = "No difficulty option selected"
        }
        
        if let cookingTimeParam = self.filterParams.cookingTime {
            self.cookingTimeSlider.setValue(cookingTimeParam.sliderPosition(), animated: true)
            self.cookingTimeSliderValue.text = cookingTimeParam.rawValue
        } else {
            self.cookingTimeSlider.setValue(0, animated: true)
            self.cookingTimeSliderValue.text = "No cooking time option selected"
        }
        
        if let lastCookingParam = self.filterParams.cookingDate {
            self.lastCookingSlider.setValue(lastCookingParam.sliderPosition(), animated: true)
            self.lastCookingSliderValueLabel.text = lastCookingParam.rawValue
        } else {
            self.lastCookingSlider.setValue(0, animated: true)
            self.lastCookingSliderValueLabel.text = "No last cooking option selected"
        }
    }
    
// MARK: - IBActions
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.delegate?.recipeFilterCanceled()
        
        removeFromSuperview()
    }
    
    @IBAction func selectCategoryPressed(_ sender: Any) {
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
    
    @IBAction func lastCookingSliderAction(_ sender: Any) {
        switch lroundf(self.lastCookingSlider.value) {
        case 0:
            self.lastCookingSliderValueLabel.text = "No last cooking option selected"
            self.filterParams.cookingDate = nil
        case 1:
            self.lastCookingSliderValueLabel.text = LastDateCriteriaStrings.never.rawValue
            self.filterParams.cookingDate = LastDateCriteriaStrings.never
        case 2:
            self.lastCookingSliderValueLabel.text = LastDateCriteriaStrings.oneWeek.rawValue
            self.filterParams.cookingDate = LastDateCriteriaStrings.oneWeek
        case 3:
            self.lastCookingSliderValueLabel.text = LastDateCriteriaStrings.twoWeeks.rawValue
            self.filterParams.cookingDate = LastDateCriteriaStrings.twoWeeks
        case 4:
            self.lastCookingSliderValueLabel.text = LastDateCriteriaStrings.oneMonthPlus.rawValue
            self.filterParams.cookingDate = LastDateCriteriaStrings.oneMonthPlus
        default:
            break
        }
    }
    
    @IBAction func cookingTimeSliderAction(_ sender: UISlider) {
        switch lroundf(self.cookingTimeSlider.value) {
        case 0:
            self.cookingTimeSliderValue.text = "No cooking time option selected"
            self.filterParams.cookingTime = nil
        case 1:
            self.cookingTimeSliderValue.text = CookingTimeCriteriaStrings.under15Min.rawValue
            self.filterParams.cookingTime = CookingTimeCriteriaStrings.under15Min
        case 2:
            self.cookingTimeSliderValue.text = CookingTimeCriteriaStrings.between16And30Mins.rawValue
            self.filterParams.cookingTime = CookingTimeCriteriaStrings.between16And30Mins
        case 3:
            self.cookingTimeSliderValue.text = CookingTimeCriteriaStrings.between31And60Mins.rawValue
            self.filterParams.cookingTime = CookingTimeCriteriaStrings.between31And60Mins
        case 4:
            self.cookingTimeSliderValue.text = CookingTimeCriteriaStrings.oneHourPlus.rawValue
            self.filterParams.cookingTime = CookingTimeCriteriaStrings.oneHourPlus
        default:
            break
        }
    }
    
    @IBAction func portionsSliderAction(_ sender: Any) {
        switch lroundf(self.portionsSlider.value) {
        case 0:
            self.portionsValueLabel.text = "No portions option selected"
            self.filterParams.portions = nil
        case 1:
            self.portionsValueLabel.text = PortionsCriteriaStrings.oneOrTwo.rawValue
            self.filterParams.portions = PortionsCriteriaStrings.oneOrTwo
        case 2:
            self.portionsValueLabel.text = PortionsCriteriaStrings.threeOrFour.rawValue
            self.filterParams.portions = PortionsCriteriaStrings.threeOrFour
        case 3:
            self.portionsValueLabel.text = PortionsCriteriaStrings.betweenFiveAndEight.rawValue
            self.filterParams.portions = PortionsCriteriaStrings.betweenFiveAndEight
        case 4:
            self.portionsValueLabel.text = PortionsCriteriaStrings.ninePlus.rawValue
            self.filterParams.portions = PortionsCriteriaStrings.ninePlus
        default:
            break
        }
    }
    
    @IBAction func dificultySliderAction(_ sender: Any) {
        switch lroundf(self.dificultySlider.value) {
        case 0:
            self.dificultySliderValueLabel.text = "No difficulty option selected"
            self.filterParams.dificulty = nil
        case 1:
            self.dificultySliderValueLabel.text = DificultyCriteriaStrings.easy.rawValue
            self.filterParams.dificulty = DificultyCriteriaStrings.easy
        case 2:
            self.dificultySliderValueLabel.text = DificultyCriteriaStrings.medium.rawValue
            self.filterParams.dificulty = DificultyCriteriaStrings.medium
        case 3:
            self.dificultySliderValueLabel.text = DificultyCriteriaStrings.hard.rawValue
            self.filterParams.dificulty = DificultyCriteriaStrings.hard
        default:
            break
        }
    }
    
// MARK: - Private selectors for Sliders
    
    @objc func cookingTimeSliderFinishedSliding() {
        self.cookingTimeSlider.setValue(Float(lroundf(self.cookingTimeSlider.value)), animated: true)
    }
    
    @objc func lastCookingSliderFinishedSliding() {
        self.lastCookingSlider.setValue(Float(lroundf(self.lastCookingSlider.value)), animated: true)
    }
    
    @objc func portionsSliderFinishedSliding() {
        self.portionsSlider.setValue(Float(lroundf(self.portionsSlider.value)), animated: true)
    }
    
    @objc func dificultySliderFinishedSliding() {
        self.dificultySlider.setValue(Float(lroundf(self.dificultySlider.value)), animated: true)
    }
    
}

extension RecipesFilterView: CategoriesViewDelegate {
    func didSelectRecipeCategory(withCategoryName name: String?) {
        filterParams.categoryString = name
        
        self.selectCategoryButton.setTitle(name ?? "Select a category", for: .normal)
    }
}
