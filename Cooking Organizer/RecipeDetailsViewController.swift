//
//  RecipeDetailsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    var recipe: Recipe?

    @IBOutlet weak var recipeNametextField: UITextField!
    @IBOutlet weak var portionsTextField: UITextField!
    
    @IBOutlet weak var cookingTimeButton: UIButton!
    @IBOutlet weak var difiicultyButton: UIButton!
    @IBOutlet weak var lastCookButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    @IBOutlet weak var ingredientsStackView: UIStackView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet weak var ingredientsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stepsStackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var recipeImageView: UIImageView!
    
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
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewsAndFieldsSetup()
        
        ingredientsStackView.distribution = .fillProportionally
        stepsStackView.distribution = .fillProportionally
        
        ingredientsStackView.spacing = 4.0
        stepsStackView.spacing = 4.0
        
        if let recipeIngredients = recipe?.ingredients, recipeIngredients.count > 0 {
            ingredients = recipeIngredients
            
            ingredientsViewSetup()
        }
        
        if let recipeSteps = recipe?.steps, recipeSteps.count > 0 {
            steps = recipeSteps
            
            stepsViewSetup()
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
    }
    
    // MARK: - Private Helper Methods
    
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
        lastCookButton.setTitle(recipe?.lastCook, for: .normal)
        categoriesButton.setTitle(recipe?.categories, for: .normal)
        
        categoriesButton.setTitleColor(UIColor.darkGray, for: .disabled)
        cookingTimeButton.setTitleColor(UIColor.darkGray, for: .disabled)
        difiicultyButton.setTitleColor(UIColor.darkGray, for: .disabled)
        lastCookButton.setTitleColor(UIColor.darkGray, for: .disabled)
        
        enableFieldsAndButtons(enable: false)
    }
    
    private func ingredientsViewSetup() {
        ingredientsStackViewHeaderSetup()
        
        ingredients.forEach { (ingredient) in
            let ingredientView = RecipeDetailsIngredientView()
            
            ingredientView.ingredientName.text = ingredient.name
            
            if let quantity = ingredient.quantityAsString,
                let unit = ingredient.unit
            {
                ingredientView.quantityAndUnit.text = quantity + unit
            }
            
            ingredientsStackView.addArrangedSubview(ingredientView)
            ingredientView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            
            ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 64.0
        }
    }
    
    private func stepsViewSetup() {
        stepsStackViewHeaderSetup()
        
        if let steps = recipe?.steps {
            for stepIndex in steps.indices {
                let step = steps[stepIndex]
                let stepView = RecipeDetailsStepView()
                
                stepView.stepNr.text = "\(stepIndex)."
                stepView.stepDescription.text = step
                
                stepsStackView.addArrangedSubview(stepView)
                NSLayoutConstraint.activate([stepView.heightAnchor.constraint(equalToConstant: 60.0)])
                
                stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 64.0
            }
        }
    }
    
    private func editIngredientsViewSetup() {
        ingredientsStackViewHeaderSetup()
        
        if let ingredients = recipe?.ingredients {
            ingredients.forEach { (ingredient) in
                let ingredientView = NewRecipeIngredientView()
                
                ingredientView.nameTextField.text = ingredient.name
                ingredientView.quantitytextField.text = ingredient.quantityAsString
                ingredientView.unitButton.setTitle(ingredient.unit, for: .normal)
                
                ingredientsStackView.addArrangedSubview(ingredientView)
                ingredientView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
                
                ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 64.0
            }
        }
    }
    
    private func editStepsViewSetup() {
        stepsStackViewHeaderSetup()
        
        if let steps = recipe?.steps {
            for stepIndex in steps.indices {
                let step = steps[stepIndex]
                let stepView = NewRecipeStepView()
                
                stepView.stepNumberLabel.text = "\(stepIndex)."
                stepView.stepTextView.text = step
                
                stepsStackView.addArrangedSubview(stepView)
                NSLayoutConstraint.activate([stepView.heightAnchor.constraint(equalToConstant: 60.0)])
                
                stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 64.0
            }
        }
    }
    
    private func enableFieldsAndButtons(enable: Bool) {
        recipeNametextField.isEnabled = enable
        portionsTextField.isEnabled = enable
        lastCookButton.isEnabled = enable
        cookingTimeButton.isEnabled = enable
        categoriesButton.isEnabled = enable
        difiicultyButton.isEnabled = enable
    }
    
    private func ingredientsStackViewHeaderSetup() {
        let ingredientsHeaderTitle = UILabel()
        
        ingredientsHeaderTitle.text = "  Ingredients:"
        
        addStyleToLabel(label: ingredientsHeaderTitle)
        
        ingredientsStackView.addArrangedSubview(ingredientsHeaderTitle)
        
        ingredientsStackViewHeightConstraint.constant = ingredientsStackViewHeightConstraint.constant + 30.0
    }
    
    private func stepsStackViewHeaderSetup() {
        let stepsHeaderTitle = UILabel()
        
        stepsHeaderTitle.text = "  Steps:"
        
        addStyleToLabel(label: stepsHeaderTitle)
        
        stepsStackView.addArrangedSubview(stepsHeaderTitle)
        
        stepsStackViewHeightConstraint.constant = stepsStackViewHeightConstraint.constant + 30.0
    }
    
    private func clearIngredientsStackView() {
        ingredientsStackViewHeightConstraint.constant = 0
        
        ingredientsStackView.subviews.forEach( { $0.removeFromSuperview() } )
    }
    
    private func clearStepsStackView() {
        stepsStackViewHeightConstraint.constant = 0
        
        stepsStackView.subviews.forEach( { $0.removeFromSuperview() } )
    }
    
    private func addStyleToLabel(label: UILabel) {
        label.textAlignment = .left
        label.layer.borderWidth = 0.2
        label.layer.cornerRadius = 5.0
        label.clipsToBounds = true
        label.backgroundColor = UIColor.systemGray4
        
        label.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    private func changedRecipeDictionary() -> [String:Any]? {
        var changedRecipeDictionary = [String:Any]()
        
        guard let recipe = recipe else { return nil }
        
        if let name = recipeNametextField.text,
            !name.isEmpty,
            name != recipe.name
        {
            changedRecipeDictionary["name"] = name
        }
        
        if let portions = portionsTextField.text,
            !portions.isEmpty,
            let portionsAsNumber = NumberFormatter().number(from: portions),
            portionsAsNumber.intValue != recipe.portions
        {
            changedRecipeDictionary["portions"] = portions
        }
        
        if (cookingTimeHours != 0 || cookingTimeMinutes != 0),
            "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes" != recipe.cookingTime
        {
            changedRecipeDictionary["cookingTime"] = "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes"
        }
        
        if let dificulty = dificulty, dificulty != recipe.dificulty {
            changedRecipeDictionary["dificulty"] = dificulty
        }
        
        if let lastCook = lastCookDateString, lastCook != recipe.lastCook {
            changedRecipeDictionary["lastCook"] = lastCook
        }
        
        if let categories = categoriesAsString, categories != recipe.categories {
            changedRecipeDictionary["categories"] = categories
        }
        
        validateChangedRecipeIngredients(success: {
            changedRecipeDictionary["ingredients"] = self.createIngredientsDictionary()
        })
        
        validateChangedRecipeSteps {
            changedRecipeDictionary["steps"] = self.createStepsDictionary()
        }
        
        if changedRecipeDictionary.isEmpty {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "No changes detected",
                                                              message: "Please check that you changed a detail of the recipe!")
            
            return nil
        } else {
            return changedRecipeDictionary
        }
    }
    
    private func createIngredientsDictionary() -> [String:Any] {
        var ingredientsDictionary = [String:Any]()
        
        changedIngredients.forEach { ingredientsDictionary["\(changedIngredients.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
        
        return ingredientsDictionary
    }
    
    private func createStepsDictionary() -> [String:Any] {
        var stepsDictionary = [String:Any]()
        
        changedSteps.forEach { stepsDictionary["\(changedSteps.firstIndex(of: $0) ?? 0)"] = $0 }
        
        return stepsDictionary
    }
    
    private func validateChangedRecipeIngredients(success: @escaping () -> Void) {
        changedIngredients.removeAll()
        
        areIngredientsChanged = false
        
        ingredientsStackView.subviews.forEach { view in
            guard let view = view as? NewRecipeIngredientView else { return }
            guard let viewIndex = ingredientsStackView.subviews.firstIndex(of: view) else { return }
            
            let originalIngredient = ingredients[viewIndex]
            
            if let changedIngredientViewName = view.nameTextField.text,
                let changedIngredientViewQuantity = view.quantitytextField.text,
                let changedIngredientViewUnit = view.unitButton.titleLabel?.text
            {
                if changedIngredientViewName.isEmpty ||
                    changedIngredientViewQuantity.isEmpty ||
                    changedIngredientViewUnit == "Unit"
                {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Incomplete Ingredients",
                                                                      message: "Please check that you completed all ingredients fields. If you left one incomplete either remove it or complete it will all dteails!")
                    
                    return
                }
                
                if changedIngredientViewName != originalIngredient.name ||
                    changedIngredientViewQuantity != originalIngredient.quantityAsString ||
                    changedIngredientViewUnit != originalIngredient.unit
                {
                    areIngredientsChanged = true
                }
                
                let ingredient = NewRecipeIngredient()
                
                ingredient.name = changedIngredientViewName
                ingredient.quantityAsString = changedIngredientViewQuantity
                ingredient.unit = changedIngredientViewUnit
                
                changedIngredients.append(ingredient)
            }
        }
        
        if areIngredientsChanged {
            success()
        }
    }
    
    private func validateChangedRecipeSteps(success: @escaping () -> Void) {
        changedSteps.removeAll()
        
        areStepsChanged = false
        
        stepsStackView.subviews.forEach { view in
            guard let view = view as? NewRecipeStepView else { return }
            guard let viewIndex = stepsStackView.subviews.firstIndex(of: view) else { return }
            
            let originalStep = steps[viewIndex]
            
            if let changedStepViewDescription = view.stepTextView.text {
                if changedStepViewDescription.isEmpty {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Incomplete Steps",
                                                                      message: "Please check that you completed step description field. If you left one incomplete either remove it or complete it with description!")
                    
                    return
                }
                
                if originalStep != changedStepViewDescription {
                    areStepsChanged = true
                }
                
                changedSteps.append(changedStepViewDescription)
            }
        }
        
        if areStepsChanged {
            success()
        }
    }
    
    // MARK: - Selectors
    
    @objc
    func editPressed() {
        clearIngredientsStackView()
        clearStepsStackView()
        
        editIngredientsViewSetup()
        editStepsViewSetup()
        
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        enableFieldsAndButtons(enable: true)
    }
    
    @objc
    func donePressed() {
        clearIngredientsStackView()
        clearStepsStackView()
        
        ingredientsViewSetup()
        stepsViewSetup()
        
        navigationItem.hidesBackButton = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        
        enableFieldsAndButtons(enable: false)
    }
}
