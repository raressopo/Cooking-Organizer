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
    
    @IBOutlet weak var recipesTableView: UITableView! {
        didSet {
            self.recipesTableView.backgroundColor = UIColor.screenBackground()
            self.recipesTableView.clipsToBounds = true
            self.recipesTableView.layer.cornerRadius = 25.0
            self.recipesTableView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBOutlet weak var buttonsBackgroundView: UIView! {
        didSet {
            buttonsBackgroundView.backgroundColor = UIColor.screenBackground()
        }
    }
    
    @IBOutlet weak var generateShoppingListButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var scheduleButton: UIButton!
    
    var allRecipes = [CookingCalendarRecipe]()
    var selectedDateRecipes = [CookingCalendarRecipe]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegateAndDataSourceSetup()
        
        generateShoppingListButton.onScreenButtonSetup(withFontName: .bold, andSize: 13.0)
        editButton.onScreenButtonSetup(withFontName: .regular)
        scheduleButton.onScreenButtonSetup(withFontName: .regular)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateAllRecipes()
        setupScreen(forDate: Date())

        recipesTableView.register(UINib(nibName: "ScheduledRecipeTableViewCell", bundle: nil), forCellReuseIdentifier: "scheduledRecipeCell")
    }
    
    // MARK: - Private Helpers
    
    private func populateAllRecipes() {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            allRecipes = userRecipes.map { CookingCalendarRecipe(name: $0.name ?? "",
                                                                 id: $0.id,
                                                                 cookingDates: $0.cookingDates ?? []) }
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
        selectedDateRecipes = allRecipes.filter({ recipe -> Bool in
            let dateFormatter = UtilsManager.shared.dateFormatter
            
            for cookingDateString in recipe.cookingDates {
                if let cookingDate = dateFormatter.date(from: cookingDateString) {
                    return UtilsManager.isSelectedDate(selectedDate: date, equalToGivenDate: cookingDate)
                }
            }
            
            return false
        })

        
        recipesTableView.reloadData()
    }
    
    private func hideTabBarAndButtons(hide: Bool) {
        self.tabBarController?.tabBar.isHidden = hide
        
        editButton.isHidden = hide
        generateShoppingListButton.isHidden = hide
        scheduleButton.isHidden = hide
    }
    
    // MARK: - IBActions
    
    @IBAction func editPressed(_ sender: Any) {
        if editButton.titleLabel?.text == "Edit" {
            generateShoppingListButton.isHidden = true
            scheduleButton.isHidden = true
            
            editButton.setTitle("Save", for: .normal)
            editButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 15.0)
            
            recipesTableView.setEditing(true, animated: true)
            
            recipesTableView.reloadData()
        } else {
            generateShoppingListButton.isHidden = false
            editButton.setTitle("Edit", for: .normal)
            editButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Regular", size: 15.0)
            scheduleButton.isHidden = false
            
            recipesTableView.setEditing(false, animated: true)
        }
    }
    
    @IBAction func generateShoppingListPressed(_ sender: Any) {
        hideTabBarAndButtons(hide: true)
        
        let generateView = GenerateShoppingListView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        generateView.delegate = self
        
        view.addSubview(generateView)
        
        generateView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([generateView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     generateView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     generateView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     generateView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func schedulePressed(_ sender: Any) {
        hideTabBarAndButtons(hide: true)
        
        let recipesView = RecipesTableView()
        
        recipesView.recipes = allRecipes.filter({ recipe -> Bool in
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

// MARK: - FSCalendar Delegate and Datasource

extension CookingCalendarViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        filterRecipesForDate(date: date)
    }
}

// MARK: - Table View Delegate and Datasource

extension CookingCalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDateRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledRecipeCell") as? ScheduledRecipeTableViewCell else {
            fatalError("Wrong cell!!!")
        }
        
        cell.recipeName.text = selectedDateRecipes[indexPath.row].name
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipe = selectedDateRecipes[indexPath.row]
            
            if let selectedCalendarDate = calendar.selectedDate, recipe.cookingDates.contains(UtilsManager.shared.dateFormatter.string(from: selectedCalendarDate)) {
                guard let cookingDateIndex = recipe.cookingDates.firstIndex(of: UtilsManager.shared.dateFormatter.string(from: selectedCalendarDate)) else {
                    // TODO: Throw error
                    return
                }
                
                AlertManager.showAlertWithTitleMessageCancelButtonAndCutomButtonAndHandler(onPresenter: self,
                                                                                           title: "Remove cooking date from recipe",
                                                                                           message: "Are you sure you want to remove selected date from cooking dates for this recipe?",
                                                                                           customButtonTitle: "Delete") { _ in
                    var cookingDates = recipe.cookingDates
                    cookingDates.remove(at: cookingDateIndex)
                    
                    UserDataManager.shared.changeCookingDates(forRecipeId: recipe.id, withValue: cookingDates) {
                        self.filterRecipesForDate(date: self.calendar.selectedDate ?? Date())
                    } failure: {
                        // TODO: Throw error
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != selectedDateRecipes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
}

// MARK: - User Data Manager Delegate

extension CookingCalendarViewController: UserDataManagerDelegate {
    func recipeChanged() {
        populateAllRecipes()
        
        filterRecipesForDate(date: calendar.selectedDate ?? Date())
        
        if selectedDateRecipes.count == 0, recipesTableView.isEditing == true {
            editPressed(self)
        }
    }
}

extension CookingCalendarViewController: RecipesTableViewDelegate {
    func recipeSelectedForSchedule(withRecipe recipe: CookingCalendarRecipe) {
        hideTabBarAndButtons(hide: false)
        
        guard let selectedCalendarDate = calendar.selectedDate else {
            return
        }
        
        UserDataManager.shared.changeCookingDates(forRecipeId: recipe.id, withValue: [UtilsManager.shared.dateFormatter.string(from: selectedCalendarDate)]) {
            self.filterRecipesForDate(date: self.calendar.selectedDate ?? Date())
        } failure: {
            // TODO: Throw error
        }
    }
    
    func recipeTableViewDismissed() {
        hideTabBarAndButtons(hide: false)
    }
}

extension CookingCalendarViewController: GenerateShoppingListViewDelegate {
    
    func viewDismissed() {
        hideTabBarAndButtons(hide: false)
    }
    
}
