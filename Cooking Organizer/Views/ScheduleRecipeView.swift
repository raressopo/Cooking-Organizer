//
//  ScheduleRecipeView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 09/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol ScheduleRecipeViewDelegate: AnyObject {
    func didScheduleRecipes()
}

class ScheduleRecipeView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
            containerView.layer.cornerRadius = 16.0
        }
    }
    
    @IBOutlet weak var recipeNameLabel: UILabel! {
        didSet {
            recipeNameLabel.adjustsFontSizeToFitWidth = true
            recipeNameLabel.font = UIFont(name: "Proxima Nova Alt Bold", size: 19.0)
        }
    }
    @IBOutlet weak var scheduleDateButton: UIButton! {
        didSet {
            scheduleDateButton.setTitleColor(UIColor.secondaryButtonColor(), for: .normal)
            scheduleDateButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 16.0)
        }
    }
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            cancelButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Light", size: 17.0)
        }
    }
    @IBOutlet weak var scheduleButton: UIButton! {
        didSet {
            scheduleButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            scheduleButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 17.0)
        }
    }
    
    weak var delegate: ScheduleRecipeViewDelegate?
    
    var selectedRecipe: GeneratedRecipe?
    var selectedDate: Date?
    
    init(withRecipe recipe: GeneratedRecipe, andFrame frame: CGRect) {
        super.init(frame: frame)
        
        self.selectedRecipe = recipe
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ScheduleRecipeView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        recipeNameLabel.text = selectedRecipe?.name ?? "Recipe"
    }
    
    @IBAction func dismissedPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func schedulePressed(_ sender: Any) {
        if let recipeId = selectedRecipe?.id, let date = selectedDate, var cookingDates = selectedRecipe?.cookingDates {
            cookingDates.append(UtilsManager.shared.dateFormatter.string(from: date))
            
            UserDataManager.shared.changeCookingDates(forRecipeId: recipeId, withValue: cookingDates) {
                self.delegate?.didScheduleRecipes()
                
                self.removeFromSuperview()
            } failure: {
                self.removeFromSuperview()
            }

        }
    }
    
    @IBAction func scheduleDatePressed(_ sender: Any) {
        let datePickerView = LastCookDatePickerView()
        
        datePickerView.neverCookedButton.removeFromSuperview()
        datePickerView.delegate = self
        
        contentView.addSubview(datePickerView)
        
        datePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([datePickerView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0.0),
                                     datePickerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0.0),
                                     datePickerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0.0),
                                     datePickerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0.0)])
    }
}

extension ScheduleRecipeView: LastCookDatePickerViewDelegate {
    func didSelectLastCookDate(date: Date?) {
        if let date = date {
            let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
            selectedDate = date
            
            scheduleDateButton.setTitle(dateString, for: .normal)
        }
    }
}
