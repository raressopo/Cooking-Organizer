//
//  CookingCalendarWidgetTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 29/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol CookingCalendarWidgetTableViewCellDelegate: class {
    func recipePressed(withDate date: Date)
}

class CookingCalendarWidgetTableViewCell: UITableViewCell {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var noRecipesScheduledLabel: UILabel!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: CookingCalendarWidgetTableViewCellDelegate?
    
    var recipes = [Recipe]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        calendar.scope = .week
        calendar.pagingEnabled = true
        calendar.setScope(.week, animated: false)
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        calendar.delegate = self
        calendar.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        setupScreen(forDate: Date())
    }
    
    private func setupScreen(forDate date: Date) {
        calendar.select(date)
        
        filterRecipesForDate(date: date)
    }
    
    func filterRecipesForDate(date: Date) {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipes = userRecipes.filter({ recipe -> Bool in
                if let cookingDates = recipe.cookingDates {
                    var isCookingDateSelectedDate = false
                    
                    for cookingDateString in cookingDates {
                        if let cookingDate = UtilsManager.shared.dateFormatter.date(from: cookingDateString), !isCookingDateSelectedDate {
                            isCookingDateSelectedDate = UtilsManager.isSelectedDate(selectedDate: date, equalToGivenDate: cookingDate)
                        }
                    }
                    
                    return isCookingDateSelectedDate
                } else {
                    return false
                }
            })
            
            noRecipesScheduledLabel.isHidden = recipes.count != 0
            
            recipesTableView.reloadData()
        }
    }
}

extension CookingCalendarWidgetTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = recipes[indexPath.row].name
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.recipePressed(withDate: calendar.selectedDate ?? Date())
    }
}

extension CookingCalendarWidgetTableViewCell: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        
        self.contentView.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        filterRecipesForDate(date: date)
    }
}

extension CookingCalendarWidgetTableViewCell: UserDataManagerDelegate {
    func recipeChanged() {
        filterRecipesForDate(date: calendar.selectedDate ?? Date())
    }
}
