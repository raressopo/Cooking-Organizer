//
//  RecipeDetailsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

class RecipeDetailsViewController: UIViewController {
    var recipe: Recipe?
    var changedRecipe = ChangedRecipe()
    
    @IBOutlet weak var changeImageButton: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    
    @IBOutlet weak var recipeNametextField: UITextField!
    @IBOutlet weak var portionsTextField: UITextField!
    
    @IBOutlet weak var cookingTimeButton: UIButton!
    @IBOutlet weak var difiicultyButton: UIButton!
    @IBOutlet weak var cookingDatesButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet weak var ingredientsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsStackViewHeightConstraint: NSLayoutConstraint!
    
    private var cookingTimeHours = 0
    private var cookingTimeMinutes = 0
    
    private var dificulty: String?
    private var lastCookDateString: String?
    
    private var categoriesAsString: String?
    
    private var ingredients = [NewRecipeIngredient]()
    private var changedIngredients = [NewRecipeIngredient]()
    
    private var steps = [String]()
    private var changedSteps = [String]()
    
    var areIngredientsChanged = false
    var areStepsChanged = false
    
    var selectedCategories = [RecipeCategories]()
    
    var ingredientsView: IngredientsView?
    var stepsView: StepsView?
    
    var cookingDateChanges: [String]?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First we have to set the ingredients and steps
        setIngredientsAndSteps()
        
        // Secondly we will create and populate the views, fields and buttons
        viewsAndFieldsSetup()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
    }
    
    // MARK: - Views Private Helpers
    
    private func viewsAndFieldsSetup() {
        if let data = recipe?.imageData {
            let dataDecode = Data(base64Encoded: data, options: .ignoreUnknownCharacters)
            
            if let imageData = dataDecode {
                let decodedImage = UIImage(data: imageData)
                
                recipeImageView.image = decodedImage
            }
        }
        
        recipeNametextField.text = recipe?.name
        portionsTextField.text = "\(recipe?.portions ?? 0)"
        cookingTimeButton.setTitle(recipe?.cookingTime, for: .normal)
        difiicultyButton.setTitle(recipe?.dificulty, for: .normal)
        cookingDatesButton.setTitle(recipe?.cookingDates != nil ? "See Cooking Dates" : "Never Cooked", for: .normal)
        categoriesButton.setTitle(recipe?.categories, for: .normal)
        
        categoriesButton.setTitleColor(UIColor.darkGray, for: .disabled)
        cookingTimeButton.setTitleColor(UIColor.darkGray, for: .disabled)
        difiicultyButton.setTitleColor(UIColor.darkGray, for: .disabled)
        cookingDatesButton.setTitleColor(UIColor.darkGray, for: .disabled)
        
        ingredientsStackViewHeaderSetup()
        stepsStackViewHeaderSetup()
        
        ingredientsViewSetup()
        stepsViewSetup()
        
        enableFieldsAndButtons(enable: false)
    }
    
    private func enableFieldsAndButtons(enable: Bool) {
        recipeNametextField.isEnabled = enable
        portionsTextField.isEnabled = enable
        cookingDatesButton.isEnabled = enable
        cookingTimeButton.isEnabled = enable
        categoriesButton.isEnabled = enable
        difiicultyButton.isEnabled = enable
        changeImageButton.isHidden = !enable
    }
    
    private func addStyleToLabel(label: UILabel) {
        label.textAlignment = .left
        label.layer.borderWidth = 0.2
        label.layer.cornerRadius = 5.0
        label.clipsToBounds = true
        label.backgroundColor = UIColor.systemGray4
        
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func setupViewAfterEditing() {
        ingredientsViewSetup()
        stepsViewSetup()
        
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
        
        enableFieldsAndButtons(enable: false)
        
        changedRecipe = ChangedRecipe()
        
        cookingDateChanges = nil
    }
    
    // MARK: - Data Handle Helpers
    
    private func setIngredientsAndSteps() {
        if let recipeIngredients = recipe?.ingredients, recipeIngredients.count > 0 {
            ingredients = recipeIngredients
        }
        
        if let recipeSteps = recipe?.steps, recipeSteps.count > 0 {
            steps = recipeSteps
        }
    }
    
    private func changedRecipeDictionary() -> [String:Any] {
        var changedRecipeDictionary = [String:Any]()
        
        guard let recipe = recipe else { return changedRecipeDictionary }
        
        // Recipe Image
        if let originalImage = recipe.imageData,
            let changedImage = changedRecipe.imageData,
            originalImage != changedImage
        {
            changedRecipeDictionary["imageData"] = changedImage
            
            recipe.imageData = changedImage
        }
        
        // Recipe Name
        if let name = recipeNametextField.text,
            !name.isEmpty,
            name != recipe.name
        {
            changedRecipeDictionary["name"] = name
        }
        
        // Portions
        if let portions = portionsTextField.text,
            !portions.isEmpty,
            let portionsAsNumber = NumberFormatter().number(from: portions),
            portionsAsNumber.intValue != recipe.portions
        {
            changedRecipeDictionary["portions"] = portionsAsNumber
        }
        
        // Cooking Time
        if (cookingTimeHours != 0 || cookingTimeMinutes != 0),
            "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes" != recipe.cookingTime
        {
            changedRecipeDictionary["cookingTime"] = "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes"
        }
        
        // Dificulty
        if let dificulty = dificulty, dificulty != recipe.dificulty {
            changedRecipeDictionary["dificulty"] = dificulty
        }
        
        // Cooking Dates
        if let changedCookingDates = cookingDateChanges, !changedCookingDates.containsSameElements(as: recipe.cookingDates ?? []) {
            changedRecipeDictionary["cookingDates"] = changedCookingDates
        }
        
        // Categories
        if let categories = categoriesAsString, categories != recipe.categories {
            changedRecipeDictionary["categories"] = categories
        }
        
        // Ingredients
        validateChangedRecipeIngredients { newIngredients in
            self.changedIngredients = newIngredients
            
            changedRecipeDictionary["ingredients"] = self.createIngredientsDictionary()
        }
        
        // Steps
        validateChangedRecipeSteps(success: { newSteps in
            self.changedSteps = newSteps
            
            changedRecipeDictionary["steps"] = self.createStepsDictionary()
        })
        
        return changedRecipeDictionary
    }
    
    // MARK: - Selectors
    
    @objc
    func editPressed() {
        editIngredientsViewSetup()
        editStepsViewSetup()
        
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        enableFieldsAndButtons(enable: true)
    }
    
    @objc
    func donePressed() {
        ingredientsView?.validateChangedIngredients(validationFailed: { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Ingredients",
                                                                  message: "Please complete all the info for all the ingredients you have or added.")
                
                return
            } else {
                self.stepsView?.validateChangedSteps(validationFailed: { failed in
                    if failed {
                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self, title: "Incomplete Steps", message: "Please make sure that you completed all steps details")
                        
                        return
                    } else {
                        let changedRecipeDetails = self.changedRecipeDictionary()
                        
                        if let userId = UsersManager.shared.currentLoggedInUser?.loginData.id,
                            let recipeId = self.recipe?.id,
                            !changedRecipeDetails.isEmpty
                        {
                            FirebaseAPIManager.sharedInstance.updateRecipe(froUserId: userId,
                                                                           andForRecipeId: recipeId,
                                                                           withDetails: changedRecipeDetails) { success in
                                                                            if success {
                                                                                self.recipe = UsersManager.shared.currentLoggedInUser!.data.recipes?[recipeId]
                                                                                
                                                                                self.setIngredientsAndSteps()
                                                                                self.setupViewAfterEditing()
                                                                            } else {
                                                                                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                                                                                  title: "Update Failed",
                                                                                                                                  message: "Something went wrong updating the recipe. Please try again later!")
                                                                            }
                            }
                        } else {
                            self.setupViewAfterEditing()
                        }
                    }
                })
            }
        })
    }
}

// MARK: - Recipe Image

extension RecipeDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: - IBActions
    
    @IBAction func changeImagePressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageData = UtilsManager.resizeImageTo450x450AsData(image: image) {
                changedRecipe.imageData = imageData.base64EncodedString()
                
                recipeImageView.image = image
            }
            
            picker.dismiss(animated: true, completion: nil)
        } else{
            print("Something went wrong")
        }
    }
}

// MARK: - Cooking Time

extension RecipeDetailsViewController: CookingTimePickerViewDelegate {
    @IBAction func cookingTimePressed(_ sender: Any) {
        let cookingTimePickerView = CookingTimePickerView()
        
        cookingTimePickerView.delegate = self
        
        self.view.addSubview(cookingTimePickerView)
        
        cookingTimePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([cookingTimePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     cookingTimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     cookingTimePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     cookingTimePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    func didSelectTime(hours: Int, minutes: Int) {
        cookingTimeHours = hours
        cookingTimeMinutes = minutes
        
        cookingTimeButton.setTitle("\(hours) hours \(minutes) minutes", for: .normal)
    }
}

// MARK: - Dificulty

extension RecipeDetailsViewController: DificultyPickerViewDelegate {
    @IBAction func dificultyPressed(_ sender: Any) {
        let dificultyPickerView = DificultyPickerView()
        
        dificultyPickerView.delegate = self
        
        view.addSubview(dificultyPickerView)
        
        dificultyPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([dificultyPickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     dificultyPickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     dificultyPickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     dificultyPickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    func didSelectDificulty(dificulty: String) {
        self.dificulty = dificulty
        
        difiicultyButton.setTitle(dificulty, for: .normal)
    }
}

// MARK: - Last Cook

extension RecipeDetailsViewController: LastCookDatePickerViewDelegate {
    @IBAction func cookingDatesPressed(_ sender: Any) {
        let cookingDatesView = CookingDatesView(withFrame: CGRect(x: 0, y: 0, width: 100, height: 100), andCookingDates: recipe?.cookingDates ?? [String]())
        
        cookingDatesView.delegate = self
        
        view.addSubview(cookingDatesView)
        
        cookingDatesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([cookingDatesView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     cookingDatesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     cookingDatesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     cookingDatesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    func didSelectLastCookDate(date: Date?) {
        if let date = date {
            let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
            lastCookDateString = dateString
        
            cookingDatesButton.setTitle(dateString, for: .normal)
        } else {
            lastCookDateString = nil
            
            cookingDatesButton.setTitle("Never Cooked", for: .normal)
        }
    }
}

// MARK: - Categories

extension RecipeDetailsViewController: CategoriesViewDelegate {
    @IBAction func categoriesPressed(_ sender: Any) {
        let categoriesView = CategoriesView()
        
        categoriesView.copyOfSelectedCategories = selectedCategories
        categoriesView.delegate = self
        
        view.addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    func didSelectCategories(categories: [RecipeCategories]) {
        selectedCategories = categories
        
        configureCategoriesButton()
    }
    
    private func configureCategoriesButton() {
        var categoriesButtonTitle = ""
        
        if selectedCategories.count == 0 {
            categoriesButtonTitle = "Categories"
        } else if selectedCategories.count == 1 {
            categoriesButtonTitle = "\(selectedCategories.first!.string)"
        } else {
            for category in selectedCategories {
                if selectedCategories.last! == category {
                    categoriesButtonTitle = categoriesButtonTitle + "\(category.string)"
                } else {
                    categoriesButtonTitle = categoriesButtonTitle + "\(category.string), "
                }
            }
        }
        
        if selectedCategories.count > 0 {
            categoriesAsString = categoriesButtonTitle
        }
        
        categoriesButton.setTitle(categoriesButtonTitle, for: .normal)
        categoriesButton.titleLabel?.textAlignment = .center
    }
}

// MARK: - Ingredients

extension RecipeDetailsViewController {
    private func ingredientsViewSetup() {
        if let ingredientsView = ingredientsView {
            ingredientsView.setEditMode(editMode: false)
            
            ingredientsView.ingredients = ingredients
            ingredientsView.tableView.reloadData()
            
            ingredientsStackViewHeightConstraint.constant = 30 + CGFloat(ingredients.count * 60)
        } else {
            ingredientsView = IngredientsView(frame: CGRect(x: 0, y: 0, width: ingredientsStackView.frame.width, height: CGFloat(ingredients.count) * 60.0))
            
            if let ingredientsView = ingredientsView {
                ingredientsView.ingredients = ingredients
                ingredientsView.delegate = self
                ingredientsView.addIngredientButton.isHidden = true
                
                ingredientsStackView.distribution = .fill
                
                ingredientsStackView.addArrangedSubview(ingredientsView)
                
                ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + (CGFloat(ingredients.count) * 60.0)
            }
        }
    }
    
    private func editIngredientsViewSetup() {
        if let ingredientsView = ingredientsView {
            ingredientsView.setEditMode(editMode: true)
            
            ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 76.0
            
            ingredientsView.addIngredientButton.addTarget(self, action: #selector(addNewIngredientPressed), for: .touchUpInside)
        }
    }
    
    @objc
    func addNewIngredientPressed() {
        ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 60.0
    }
    
    private func ingredientsStackViewHeaderSetup() {
        let ingredientsHeaderTitle = UILabel()
        
        ingredientsHeaderTitle.text = "  Ingredients:"
        
        addStyleToLabel(label: ingredientsHeaderTitle)
        
        ingredientsStackView.addArrangedSubview(ingredientsHeaderTitle)
        
        ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 30.0
    }
    
    private func clearIngredientsStackView() {
        ingredientsStackViewHeightConstraint.constant = 0
        
        ingredientsStackView.subviews.forEach( { $0.removeFromSuperview() } )
    }
    
    private func createIngredientsDictionary() -> [String:Any] {
        var ingredientsDictionary = [String:Any]()
        
        changedIngredients.forEach { ingredientsDictionary["\(changedIngredients.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
        
        return ingredientsDictionary
    }
    
    private func validateChangedRecipeIngredients(success: @escaping ([NewRecipeIngredient]) -> Void) {
        if let ingredientsView = self.ingredientsView, ingredientsView.areIngredientsChanged() {
            success(ingredientsView.ingredientsCopy)
        }
    }
}

// MARK: - Steps

extension RecipeDetailsViewController {
    private func stepsViewSetup() {
        if let stepsView = stepsView {
            stepsView.setEditMode(editMode: false)
            
            stepsView.steps = steps
            stepsView.tableView.reloadData()
            
            stepsStackViewHeightConstraint.constant = 30 + CGFloat(steps.count * 60)
        } else {
            stepsView = StepsView(frame: CGRect(x: 0, y: 0, width: stepsStackView.frame.width, height: CGFloat(steps.count * 60)))
            
            if let stepsView = stepsView {
                stepsView.steps = steps
                stepsView.delegate = self
                
                stepsStackView.distribution = .fill
                stepsStackView.addArrangedSubview(stepsView)
                
                stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + CGFloat(steps.count * 60)
            }
        }
    }
    
    private func editStepsViewSetup() {
        if let stepsView = stepsView {
            stepsView.setEditMode(editMode: true)
            
            stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 76.0
            
            stepsView.addStepButton.addTarget(self, action: #selector(addNewStepPressed), for: .touchUpInside)
        }
    }
    
    @objc
    func addNewStepPressed() {
        stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 60.0
    }
    
    private func stepsStackViewHeaderSetup() {
        let stepsHeaderTitle = UILabel()
        
        stepsHeaderTitle.text = "  Steps:"
        
        addStyleToLabel(label: stepsHeaderTitle)
        
        stepsStackView.addArrangedSubview(stepsHeaderTitle)
        
        stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 30.0
    }
    
    private func clearStepsStackView() {
        stepsStackViewHeightConstraint.constant = 0
        
        stepsStackView.subviews.forEach( { $0.removeFromSuperview() } )
    }
    
    private func createStepsDictionary() -> [String:Any] {
        var stepsDictionary = [String:Any]()
        
        changedSteps.forEach { stepsDictionary["\(changedSteps.firstIndex(of: $0) ?? 0)"] = $0 }
        
        return stepsDictionary
    }
    
    private func validateChangedRecipeSteps(success: @escaping ([String]) -> Void) {
        if let stepsView = self.stepsView, stepsView.areStepsChanged() {
            success(stepsView.stepsCopy)
        }
    }
}

extension RecipeDetailsViewController: IngredientsViewDelegate {
    func ingredientDeleted() {
        ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant - 60.0
    }
}

extension RecipeDetailsViewController: StepsViewDelegate {
    func stepDeleted() {
        stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant - 60.0
    }
}

extension RecipeDetailsViewController: CookingDatesViewDelegate {
    func cokingDatesChanged(withDates dates: [String]) {
        cookingDateChanges = dates
        
        cookingDatesButton.setTitle(cookingDateChanges != nil ? "See Cooking Dates" : "Never Cooked", for: .normal)
    }
}
