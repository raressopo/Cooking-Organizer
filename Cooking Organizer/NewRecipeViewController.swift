//
//  NewRecipeViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class NewRecipeViewController: UIViewController, NewRecipeIngredientViewDelegate, UnitPickerViewDelegate, CookingTimePickerViewDelegate, DificultyPickerViewDelegate, LastCookDatePickerViewDelegate, CategoriesViewDelegate, NewRecipeStepViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Recipe Name View
    @IBOutlet weak var addRecipeImage: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var cookingTimeButton: UIButton!
    @IBOutlet weak var portionsTextField: UITextField!
    
    private var cookingTimeHours = 0
    private var cookingTimeMinutes = 0
    
    // MARK: - Dificulty and Last Cook View
    @IBOutlet weak var dificultyButton: UIButton!
    @IBOutlet weak var lastCookButton: UIButton!
    
    // MARK: - Categories View
    @IBOutlet weak var categoriesButton: UIButton!
    
    var selectedCategories = [RecipeCategories]()
    
    // MARK: - Ingredients View
    @IBOutlet weak var ingredientsView: UIView!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    @IBOutlet weak var ingredientsViewHeightConstraint: NSLayoutConstraint!
    
    private var ingredients = [NewRecipeIngredient]()
    private var presentedRecipeIngredientUnitView: NewRecipeIngredientView?
    
    // MARK: - Steps View
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet weak var stepsViewHeightConstraint: NSLayoutConstraint!
    
    private var steps = [String]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - IBActions
    
    @IBAction func addIngredientPressed(_ sender: Any) {
        if ingredients.isEmpty,
            ingredientsStackView.subviews.isEmpty
        {
            addIngredientViewToStackView()
        } else if ingredients.isEmpty,
            let view = ingredientsStackView.subviews[0] as? NewRecipeIngredientView,
            let ingredientName = view.nameTextField.text,
            !ingredientName.isEmpty,
            let quantity = view.quantitytextField.text,
            !quantity.isEmpty,
            let unit = view.selectedUnit
        {
            addIngredientToIngredients(ingredientName: ingredientName, quantity: quantity, unit: unit)
        } else if let view = ingredientsStackView.subviews[ingredients.count] as? NewRecipeIngredientView,
            let ingredientName = view.nameTextField.text,
            !ingredientName.isEmpty,
            let quantity = view.quantitytextField.text,
            !quantity.isEmpty,
            let unit = view.selectedUnit
        {
            addIngredientToIngredients(ingredientName: ingredientName, quantity: quantity, unit: unit)
        }
    }
    
    @IBAction func addStepPressed(_ sender: Any) {
        if steps.isEmpty,
            stepsStackView.subviews.isEmpty {
            addStepViewToStackView()
        } else if steps.isEmpty, let view = stepsStackView.subviews[0] as? NewRecipeStepView, let step = view.stepTextView.text, !step.isEmpty {
            addStepToSteps(stepDescription: step)
        } else if let view = stepsStackView.subviews[steps.count] as? NewRecipeStepView, let step = view.stepTextView.text, !step.isEmpty {
            addStepToSteps(stepDescription: step)
        }
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
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
    
    @IBAction func lastCookPressed(_ sender: Any) {
        let lastCookDatePickerView = LastCookDatePickerView()
        
        lastCookDatePickerView.delegate = self
        
        view.addSubview(lastCookDatePickerView)
        
        lastCookDatePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([lastCookDatePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     lastCookDatePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     lastCookDatePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     lastCookDatePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
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
    
    // MARK: - View private helpers
    
    private func addBorderToLayer(layer: CALayer) {
        layer.cornerRadius = 5.0
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func addBackgroundColorToButton(button: UIButton) {
        button.layer.cornerRadius = 5.0
        button.backgroundColor = UIColor.systemGray5
    }
    
    private func setupViews() {
        addBorderToLayer(layer: addRecipeImage.layer)
        addBorderToLayer(layer: ingredientsView.layer)
        addBorderToLayer(layer: stepsView.layer)
        
        addBackgroundColorToButton(button: cookingTimeButton)
        addBackgroundColorToButton(button: dificultyButton)
        addBackgroundColorToButton(button: lastCookButton)
        addBackgroundColorToButton(button: categoriesButton)
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
        
        categoriesButton.setTitle(categoriesButtonTitle, for: .normal)
        categoriesButton.titleLabel?.textAlignment = .center
    }
    
    // MARK: - Ingredients and Steps Private Helper Functions
    
    private func addIngredientToIngredients(ingredientName: String, quantity: String, unit: String) {
        let ingredient = NewRecipeIngredient()
        
        ingredient.name = ingredientName
        ingredient.quantityAsString = quantity
        ingredient.unit = unit
        
        ingredients.append(ingredient)
        
        addIngredientViewToStackView()
    }
    
    private func addIngredientViewToStackView() {
        let ingredientView = NewRecipeIngredientView()
        
        ingredientsStackView.addArrangedSubview(ingredientView)
        
        ingredientView.delegate = self
        
        ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant + 60.0
    }
    
    private func addStepToSteps(stepDescription description: String) {
        steps.append(description)
        
        addStepViewToStackView()
    }
    
    private func addStepViewToStackView() {
        let stepView = NewRecipeStepView()
        
        stepsStackView.addArrangedSubview(stepView)
        
        stepView.delegate = self
        stepView.stepNumberLabel.text = "\(steps.count + 1)."
        
        stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant + 80
    }
    
    // MARK: - NewRecipeIngredientView Delegate
    
    func deletePressed(withIngredientName name: String) {
        if let view = ingredientsStackView.subviews.first(where: { (view) -> Bool in
            if let view = view as? NewRecipeIngredientView, view.nameTextField.text == name {
                return true
            } else {
                return false
            }
        }) {
            ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant - 60.0
            
            view.removeFromSuperview()
            
            if let ingredientIndex = ingredients.firstIndex(where: { (ingredient) -> Bool in
                return ingredient.name == name
            }) {
                ingredients.remove(at: ingredientIndex)
            }
        }
    }
    
    func unitPressed(withView view: NewRecipeIngredientView) {
        let unitPickerView = UnitPickerView()
        
        unitPickerView.delegate = self
        
        self.view.addSubview(unitPickerView)
        
        unitPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([unitPickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     unitPickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     unitPickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     unitPickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
        
        presentedRecipeIngredientUnitView = view
    }
    
    func didSelectUnit(unit: String) {
        if let view = presentedRecipeIngredientUnitView {
            view.selectedUnit = unit
        }
    }
    
    // MARK: - NewRecipeStepView delegate
    
    func deletedPressed(withStepNumber stepNr: Int, fromView view: NewRecipeStepView) {
        if steps.count >= stepNr {
            stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant - 80
            
            steps.remove(at: stepNr - 1)
            
            view.removeFromSuperview()
        }
    }
    
    // MARK: - UIImagePickerController delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            recipeImageView.image = image
            
            addRecipeImage.isHidden = true
            
            picker.dismiss(animated: true, completion: nil)
        } else{
            print("Something went wrong")
        }
    }
    
    // MARK: - Cooking Time Picker View delegate
    
    func didSelectTime(hours: Int, minutes: Int) {
        cookingTimeHours = hours
        cookingTimeMinutes = minutes
        
        cookingTimeButton.setTitle("\(hours) hours \(minutes) minutes", for: .normal)
    }
    
    // MARK: - Dificulty Picker View delegate
    
    func didSelectDificulty(dificulty: String) {
        dificultyButton.setTitle(dificulty, for: .normal)
    }
    
    // MARK: - Last Cook Picker Date delegate
    
    func didSelectLastCookDate(date: Date) {
        let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
        lastCookButton.setTitle(dateString, for: .normal)
    }
    
    // MARK: - Categories View delegate
    
    func didSelectCategories(categories: [RecipeCategories]) {
        selectedCategories = categories
        
        configureCategoriesButton()
    }
}
