//
//  CookingCalendarViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class CookingCalendarViewController: UIViewController {
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var recipesTableView: UITableView!
    
    var recipes = [Recipe]()
    var unscheduledRecipesIds = [String]()
    
    var homeScreenDate: Date?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editButton.layer.cornerRadius = 8.0
        editButton.layer.borderWidth = 3.0
        editButton.layer.borderColor = UIColor.systemRed.cgColor
        
        delegateAndDataSourceSetup()
        setupScreen(forDate: homeScreenDate ?? Date())
    }
    
    // MARK: - Private Helpers
    
    private func delegateAndDataSourceSetup() {
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        calendar.delegate = self
        calendar.dataSource = self
        
        UserDataManager.shared.delegate = self
    }
    
    private func setupScreen(forDate date: Date) {
        calendar.select(date)
        
        filterRecipesForDate(date: date)
    }
    
    private func filterRecipesForDate(date: Date) {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipes = userRecipes.filter({ recipe -> Bool in
                if let lastCook = recipe.lastCook, let lastCookDate = UtilsManager.shared.dateFormatter.date(from: lastCook) {
                    let calendar = Calendar.current
                    
                    let lastCookDay = calendar.component(.day, from: lastCookDate)
                    let lastCookMonth = calendar.component(.month, from: lastCookDate)
                    let lastCookYear = calendar.component(.year, from: lastCookDate)
                    
                    let selectedDateDay = calendar.component(.day, from: date)
                    let selectedDateMonth = calendar.component(.month, from: date)
                    let selectedDateYear = calendar.component(.year, from: date)
                    
                    return lastCookDay == selectedDateDay && lastCookMonth == selectedDateMonth && lastCookYear == selectedDateYear
                } else {
                    return false
                }
            })
            
            editButton.layer.borderColor = recipes.count == 0 ? UIColor.systemGray.cgColor : UIColor.systemRed.cgColor
            editButton.isEnabled = recipes.count != 0
            
            recipesTableView.reloadData()
        }
    }
    
    private func saveChangesToDB(withDate date: Date?) {
        let unscheduleGroup = DispatchGroup()
        
        for recipeId in self.unscheduledRecipesIds {
            unscheduleGroup.enter()
            
            UserDataManager.shared.changeLastCook(forRecipeId: recipeId, withValue: "Never Cooked") {
                unscheduleGroup.leave()
            } failure: {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Changes Failed",
                                                                  message: "Something went wrong unscheduling the recipe. Please try again later!")
                
                unscheduleGroup.leave()
            }
        }
        
        unscheduleGroup.notify(queue: .main) {
            self.unscheduledRecipesIds.removeAll()
            
            self.exitEditModeSetup()
            
            if let date = date {
                self.setupScreen(forDate: date)
            }
        }
    }
    
    private func exitEditModeSetup() {
        navigationItem.hidesBackButton = false
        
        editButton.setTitle("Edit", for: .normal)
        
        recipesTableView.setEditing(false, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func editPressed(_ sender: Any) {
        if editButton.titleLabel?.text == "Edit" {
            navigationItem.hidesBackButton = true
            
            editButton.setTitle("Save", for: .normal)
            
            recipesTableView.setEditing(true, animated: true)
        } else {
            saveChangesToDB(withDate: nil)
        }
    }
}

// MARK: - FSCalendar Delegate and Datasource

extension CookingCalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeScreenDate = nil
        
        filterRecipesForDate(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if !unscheduledRecipesIds.isEmpty {
            AlertManager.showDiscardAndSaveAlert(onPresenter: self,
                                                 withTitle: "Changes not saved",
                                                 message: "Your unscheduled recipes are not saved. Please choose if you want to save or discard changes") { _ in
                self.unscheduledRecipesIds.removeAll()
                
                self.exitEditModeSetup()
                self.setupScreen(forDate: date)
            } saveButtonHandler: { _ in
                self.saveChangesToDB(withDate: date)
            }
            
            return false
        } else {
            self.exitEditModeSetup()
            
            return true
        }
    }
}

// MARK: - Table View Delegate and Datasource

extension CookingCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.selectionStyle = .none
        
        cell.textLabel?.text = recipes[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            unscheduledRecipesIds.append(recipes[indexPath.row].id)
            recipes.remove(at: indexPath.row)
            
            tableView.reloadData()
        }
    }
}

// MARK: - User Data Manager Delegate

extension CookingCalendarViewController: UserDataManagerDelegate {
    func recipeChanged() {
        if let date = calendar.selectedDate {
            filterRecipesForDate(date: date)
        }
    }
}
