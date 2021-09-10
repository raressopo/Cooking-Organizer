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
    @IBOutlet weak var recipesTableView: UITableView!
    @IBOutlet weak var generateShoppingListButton: UIButton!
    
    var allRecipes = [CookingCalendarRecipe]()
    var allRecipesCopy = [CookingCalendarRecipe]()
    
    var filteredRecipes = [CookingCalendarRecipe]()
    var changedRecipesCookingDatesIds = [String]()
    
    var homeScreenDate: Date?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .done, target: self, action: #selector(editPressed))
        
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.title = "Edit"
        }
        
        delegateAndDataSourceSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateAllRecipes()

        setupScreen(forDate: homeScreenDate ?? Date())
    }
    
    // MARK: - Private Helpers
    
    private func populateAllRecipes() {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            allRecipes = userRecipes.map { CookingCalendarRecipe(name: $0.name ?? "", id: $0.id, cookingDates: $0.cookingDates ?? []) }
        }
    }
    
    private func delegateAndDataSourceSetup() {
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
        
        recipesTableView.allowsSelectionDuringEditing = true
        
        calendar.delegate = self
        calendar.dataSource = self
        
        UserDataManager.shared.delegate = self
    }
    
    private func setupScreen(forDate date: Date) {
        calendar.select(date)
        
        filterRecipesForDate(date: date)
    }
    
    private func filterRecipesForDate(date: Date) {
        let recipes = recipesTableView.isEditing ? allRecipesCopy : allRecipes
        
        filteredRecipes = recipes.filter({ recipe -> Bool in
            var isCookingDateSelectedDate = false
            
            for cookingDateString in recipe.cookingDates {
                if let cookingDate = UtilsManager.shared.dateFormatter.date(from: cookingDateString), !isCookingDateSelectedDate {
                    isCookingDateSelectedDate = UtilsManager.isSelectedDate(selectedDate: date, equalToGivenDate: cookingDate)
                }
            }
            
            return isCookingDateSelectedDate
        })
        
        recipesTableView.reloadData()
    }
    
    private func saveChangesToDB(withDate date: Date?) {
        let scheduleGroup = DispatchGroup()
        
        for recipeId in changedRecipesCookingDatesIds {
            scheduleGroup.enter()
            
            if let recipeCookingDates = allRecipesCopy.first(where: { $0.id == recipeId })?.cookingDates {
                UserDataManager.shared.changeCookingDates(forRecipeId: recipeId, withValue: recipeCookingDates) {
                    scheduleGroup.leave()
                } failure: {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Changes Failed",
                                                                      message: "Something went wrong unscheduling the recipe. Please try again later!")
                    
                    scheduleGroup.leave()
                }
            }
        }
        
        scheduleGroup.notify(queue: .main) {
            self.populateAllRecipes()
            
            self.changedRecipesCookingDatesIds.removeAll()
            
            self.exitEditModeSetup()
            
            if let date = date {
                self.setupScreen(forDate: date)
            }
        }
    }
    
    private func exitEditModeSetup() {
        generateShoppingListButton.isHidden = false
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = false
        
        if let rightBarButton = navigationItem.rightBarButtonItem {
            rightBarButton.title = "Edit"
        }
        
        recipesTableView.setEditing(false, animated: true)
        
        recipesTableView.reloadData()
    }
    
    private func validateRecipeCookingDatesChanges() {
        if changedRecipesCookingDatesIds.isEmpty {
            exitEditModeSetup()
        } else {
            AlertManager.showDiscardAndSaveAlert(onPresenter: self, withTitle: "Changes not saved", message: "You have unsaved changes! Please choose if you want to discard or to send the changes to DB") { _ in
                self.exitEditModeSetup()
                
                self.setupScreen(forDate: self.calendar.selectedDate ?? Date())
            } saveButtonHandler: { _ in
                self.saveChangesToDB(withDate: nil)
            }
        }
    }
    
    private func shouldDisplayScheduleRecipeCell() -> Bool {
        if let selectedDate = calendar.selectedDate {
            return UtilsManager.isSelectedDate(selectedDate: selectedDate, inFutureOrInPresentToGivenDate: Date())
        } else {
            return false
        }
    }
    
    // MARK: - IBActions
    
    @objc func editPressed() {
        if let rightBarButton = navigationItem.rightBarButtonItem, rightBarButton.title == "Edit" {
            generateShoppingListButton.isHidden = true
            
            navigationItem.hidesBackButton = true
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelPressed))
            
            rightBarButton.title = "Save"
            
            allRecipesCopy = allRecipes
            
            recipesTableView.setEditing(true, animated: true)
            
            recipesTableView.reloadData()
        } else {
            if !changedRecipesCookingDatesIds.isEmpty {
                saveChangesToDB(withDate: calendar.selectedDate)
            } else {
                exitEditModeSetup()
            }
        }
    }
    
    @objc func cancelPressed() {
        validateRecipeCookingDatesChanges()
        
        recipesTableView.reloadData()
    }
    
    @IBAction func generateShoppingListPressed(_ sender: Any) {
        let generateView = GenerateShoppingListView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        view.addSubview(generateView)
        
        generateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([generateView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     generateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     generateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     generateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
}

// MARK: - FSCalendar Delegate and Datasource

extension CookingCalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        homeScreenDate = nil
        
        filterRecipesForDate(date: date)
    }
}

// MARK: - Table View Delegate and Datasource

extension CookingCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing && shouldDisplayScheduleRecipeCell() ? filteredRecipes.count + 1 : filteredRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing, shouldDisplayScheduleRecipeCell(), indexPath.row == filteredRecipes.count {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "scheduleRecipeCell")
            
            cell.selectionStyle = .none
            
            cell.textLabel?.text = "Schedule Recipe"
            cell.textLabel?.textColor = filteredRecipes.count == allRecipesCopy.count ? .systemGray3 : .systemBlue
            cell.textLabel?.textAlignment = .center
            
            return cell
            
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "recipeCell")
        
            cell.selectionStyle = .none
        
            cell.textLabel?.text = filteredRecipes[indexPath.row].name
        
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let changedRecipeIndex = allRecipesCopy.firstIndex { recipeCopy -> Bool in
                return recipeCopy.id == filteredRecipes[indexPath.row].id
            }
            
            guard let index = changedRecipeIndex else { return }
            
            if let selectedDate = calendar.selectedDate {
                let dateIndex = allRecipesCopy[index].cookingDates.firstIndex { dateString -> Bool in
                    guard let date = UtilsManager.shared.dateFormatter.date(from: dateString) else { return false }
                    
                    return UtilsManager.isSelectedDate(selectedDate: selectedDate, equalToGivenDate: date)
                }
                
                guard let cookingDateIndex = dateIndex else { return }
                
                allRecipesCopy[index].cookingDates.remove(at: cookingDateIndex)
            }
            
            if !changedRecipesCookingDatesIds.contains(filteredRecipes[indexPath.row].id) {
                changedRecipesCookingDatesIds.append(filteredRecipes[indexPath.row].id)
            }
            
            if allRecipes[index].cookingDates.containsSameElements(as: allRecipesCopy[index].cookingDates) {
                if let changedRecipeIdIndex = changedRecipesCookingDatesIds.firstIndex(where: { $0 == filteredRecipes[indexPath.row].id }) {
                    changedRecipesCookingDatesIds.remove(at: changedRecipeIdIndex)
                }
            }
            
            filterRecipesForDate(date: calendar.selectedDate ?? Date())
            
            recipesTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != filteredRecipes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing, indexPath.row == filteredRecipes.count, filteredRecipes.count != allRecipesCopy.count {
            let recipesView = RecipesTableView()
            
            recipesView.recipes = allRecipesCopy.filter({ recipe -> Bool in
                var isRecipeScheduledForSelectedDay = false
                
                if let selectedDate = calendar.selectedDate {
                    for cookingDateString in recipe.cookingDates {
                        guard let cookingDate = UtilsManager.shared.dateFormatter.date(from: cookingDateString) else {
                            return false
                        }
                        
                        if !isRecipeScheduledForSelectedDay {
                            isRecipeScheduledForSelectedDay = UtilsManager.isSelectedDate(selectedDate: selectedDate, equalToGivenDate: cookingDate)
                        }
                    }
                }
                
                return !isRecipeScheduledForSelectedDay
            })
            
            recipesView.delegate = self
            
            view.addSubview(recipesView)
            
            recipesView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([recipesView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                         recipesView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                         recipesView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                         recipesView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
        }
    }
    
}

// MARK: - User Data Manager Delegate

extension CookingCalendarViewController: UserDataManagerDelegate {
    func recipeChanged() {
        populateAllRecipes()
        
        if let date = calendar.selectedDate {
            filterRecipesForDate(date: date)
        }
    }
}

extension CookingCalendarViewController: RecipesTableViewDelegate {
    func recipeSelectedForSchedule(withRecipe recipe: CookingCalendarRecipe) {
        let changedRecipeIndex = allRecipesCopy.firstIndex { recipeCopy -> Bool in
            return recipeCopy.id == recipe.id
        }
        
        guard let index = changedRecipeIndex else { return }
        
        if let selectedDate = calendar.selectedDate {
            allRecipesCopy[index].cookingDates.append(UtilsManager.shared.dateFormatter.string(from: selectedDate))
        }
        
        if !changedRecipesCookingDatesIds.contains(recipe.id) {
            changedRecipesCookingDatesIds.append(recipe.id)
        }
        
        if allRecipes[index].cookingDates.containsSameElements(as: allRecipesCopy[index].cookingDates) {
            if let changedRecipeIdIndex = changedRecipesCookingDatesIds.firstIndex(where: { $0 == recipe.id }) {
                changedRecipesCookingDatesIds.remove(at: changedRecipeIdIndex)
            }
        }
        
        filterRecipesForDate(date: calendar.selectedDate ?? Date())
        
        recipesTableView.reloadData()
    }
}
