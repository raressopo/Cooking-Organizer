//
//  HomeIngredientsFilterView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 24/01/2023.
//  Copyright © 2023 Rares Soponar. All rights reserved.
//

import UIKit

protocol HomeIngredientsFilterViewDelegate: AnyObject {
    func filterCanceledPressed()
}

extension HomeIngredientsFilterViewDelegate {
    func filterCanceledPressed() {}
}

enum ExpirationDateCriteriaStrings: String {
    case expired = "Expired"
    case oneWeek = "1 week availability"
    case twoWeeks = "2 weeks availability"
    case oneMonthPlus = "At least 1 month availability"
    
    func sliderPosition() -> Float {
        switch self {
        case .expired:
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

struct HomeIngredientsFilterParams {
    var categoryString: String?
    var expirationDate: ExpirationDateCriteriaStrings?
}

class HomeIngredientsFilterView: UIView {
    
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
    
    @IBOutlet var criteriaContainerViews: [UIView]! {
        didSet {
            self.criteriaContainerViews.forEach { containerView in
                containerView.layer.borderWidth = 2.0
                containerView.layer.borderColor = UIColor.hexStringToUIColor(hex: "#0D4435").cgColor
                containerView.clipsToBounds = true
                containerView.layer.cornerRadius = 17.0
            }
        }
    }
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var selectCategoryButton: UIButton! {
        didSet {
            self.selectCategoryButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    
    @IBOutlet weak var expirationDateSlider: UISlider! {
        didSet {
            self.expirationDateSlider.tintColor = UIColor.buttonTitleColor()
        }
    }
    
    @IBOutlet weak var expirationDateSliderValue: UILabel!
    
    var filterParams = HomeIngredientsFilterParams(categoryString: nil, expirationDate: nil)
    
    weak var delegate: HomeIngredientsFilterViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("HomeIngredientsFilterView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        self.expirationDateSlider.addTarget(self, action: #selector(expirationDateSliderFinishedSliding), for: .touchUpInside)
    }
    
    func configure(withFilterParams filterParams: HomeIngredientsFilterParams?) {
        if let params = filterParams {
            self.filterParams = params
        }
        
        if let categoryParam = self.filterParams.categoryString {
            self.selectCategoryButton.setTitle(categoryParam, for: .normal)
        } else {
            self.selectCategoryButton.setTitle("Select a category", for: .normal)
        }
        
        if let expirationDateParam = self.filterParams.expirationDate {
            self.expirationDateSlider.setValue(expirationDateParam.sliderPosition(), animated: true)
            self.expirationDateSliderValue.text = expirationDateParam.rawValue
        } else {
            self.expirationDateSlider.setValue(0, animated: true)
            self.expirationDateSliderValue.text = "No expiration date option selected"
        }
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.delegate?.filterCanceledPressed()
        
        removeFromSuperview()
    }
    
    @IBAction func selectCategoryPressed(_ sender: Any) {
        let categoriesView = HomeIngredientsCategoriesView()

        categoriesView.selectedCategoryName = filterParams.categoryString
        categoriesView.delegate = self
        
        addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func expirationDateSliderAction(_ sender: Any) {
        switch lroundf(self.expirationDateSlider.value) {
        case 0:
            self.expirationDateSliderValue.text = "No expiration date option selected"
            self.filterParams.expirationDate = nil
        case 1:
            self.expirationDateSliderValue.text = ExpirationDateCriteriaStrings.expired.rawValue
            self.filterParams.expirationDate = ExpirationDateCriteriaStrings.expired
        case 2:
            self.expirationDateSliderValue.text = ExpirationDateCriteriaStrings.oneWeek.rawValue
            self.filterParams.expirationDate = ExpirationDateCriteriaStrings.oneWeek
        case 3:
            self.expirationDateSliderValue.text = ExpirationDateCriteriaStrings.twoWeeks.rawValue
            self.filterParams.expirationDate = ExpirationDateCriteriaStrings.twoWeeks
        case 4:
            self.expirationDateSliderValue.text = ExpirationDateCriteriaStrings.oneMonthPlus.rawValue
            self.filterParams.expirationDate = ExpirationDateCriteriaStrings.oneMonthPlus
        default:
            break
        }
    }
    
    @objc func expirationDateSliderFinishedSliding() {
        self.expirationDateSlider.setValue(Float(lroundf(self.expirationDateSlider.value)), animated: true)
    }
}

extension HomeIngredientsFilterView: CategoriesViewDelegate {
    
    func didSelectHICategory(withCategoryName name: String) {
        filterParams.categoryString = name
        
        self.selectCategoryButton.setTitle(name, for: .normal)
    }
    
}
