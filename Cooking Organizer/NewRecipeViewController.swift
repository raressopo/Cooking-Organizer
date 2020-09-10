//
//  NewRecipeViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

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
    
    private var dificulty: String?
    private var lastCookDateString: String?
    
    // MARK: - Categories View
    @IBOutlet weak var categoriesButton: UIButton!
    
    var selectedCategories = [RecipeCategories]()
    
    private var categoriesAsString: String?
    
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
        addIngredientViewToStackView()
    }
    
    @IBAction func addStepPressed(_ sender: Any) {
        addStepViewToStackView()
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
    
    @IBAction func createRecipePressed(_ sender: Any) {
        guard let image = recipeImageView.image,
            let imageData = image.jpegData(compressionQuality: 0.0) else
        {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Image Unavailable",
                                                              message: "Please check that you selected a image for this recipe. If not please choose one!")
            
            return
        }

        guard let recipeName = recipeNameTextField.text,
            !recipeName.isEmpty else
        {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Recipe Name Unavailable",
                                                              message: "Please check that you enetered a valid recipe name!")

            return
        }

        guard let portionsString = portionsTextField.text,
            let portionsNumber = NumberFormatter().number(from: portionsString) else
        {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Portions Unavailable",
                                                              message: "Please check that you enetered a valid portions value. (Ex. 1, 4, 11, 20 etc.)")
            
            return
        }

        if cookingTimeHours == 0, cookingTimeMinutes == 0 {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Cooking Time Unavailable",
                                                              message: "Please check that you selected a valid cooking time!")
            
            return
        }

        let cookingTime = "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes"

        guard let dificulty = dificulty else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Dificulty Unavailable",
                                                              message: "Please check that you selected a valid dificulty!")
            
            return
        }

        guard let lastCook = lastCookDateString else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Last Cook Unavailable",
                                                              message: "Please check that you selected a last cook date!")
            
            return
        }

        guard let selectedCategoriesString = categoriesAsString else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Categories Unavailable",
                                                              message: "Please check that you selected at least one category!")
            
            return
        }
        
        validateNewRecipeIngredients()
        
        if ingredients.count == 0 {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Ingredients Unavailable",
                                                              message: "Please check that you add at least one ingredient!")
            
            return
        }
        
        validateNewRecipeSteps()
        
        if steps.count == 0 {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Steps Unavailable",
                                                              message: "Please check that you add at least one step!")
            
            return
        }
        
        let id = UUID().uuidString
        
        let recipeDictionary = ["name": recipeName,
                                "imageData": imageData.base64EncodedString(),
                                "portions": portionsNumber,
                                "cookingTime": cookingTime,
                                "dificulty": dificulty,
                                "lastCook": lastCook,
                                "categories": selectedCategoriesString,
                                "ingredients": createIngredientsDictionary(),
                                "steps": createStepsDictionary(),
                                "id": id] as [String:Any]
        
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }

        Database.database().reference().child("usersData")
            .child(loggedInUserId)
            .child("recipes")
            .child(id)
            .setValue(recipeDictionary) { (error, ref) in
                if error == nil {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Recipe Adding Failed",
                                                                      message: "Something went wrong ")
                }
        }
    }
    
    // MARK: - View private helpers
    
    private func createIngredientsDictionary() -> [String:Any] {
        var ingredientsDictionary = [String:Any]()
        
        ingredients.forEach { ingredientsDictionary["\(ingredients.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
        
        return ingredientsDictionary
    }
    
    private func createStepsDictionary() -> [String:Any] {
        var stepsDictionary = [String:Any]()
        
        steps.forEach { stepsDictionary["\(steps.firstIndex(of: $0) ?? 0)"] = $0 }
        
        return stepsDictionary
    }
    
    private func validateNewRecipeIngredients() {
        ingredients.removeAll()
        
        ingredientsStackView.subviews.forEach { view in
            guard let view = view as? NewRecipeIngredientView else { return }
            
            if let ingredientViewName = view.nameTextField.text,
                let ingredientViewQuantity = view.quantitytextField.text,
                let ingredientViewUnit = view.unitButton.titleLabel?.text
            {
                if ingredientViewName.isEmpty ||
                    ingredientViewQuantity.isEmpty ||
                    ingredientViewUnit == "Unit"
                {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Incomplete Ingredients",
                                                                      message: "Please check that you completed all ingredients fields. If you left one incomplete either remove it or complete it will all dteails!")
                    
                    return
                }
                
                let ingredient = NewRecipeIngredient()
                
                ingredient.name = ingredientViewName
                ingredient.quantityAsString = ingredientViewQuantity
                ingredient.unit = ingredientViewUnit
                
                ingredients.append(ingredient)
            }
        }
    }
    
    private func validateNewRecipeSteps() {
        steps.removeAll()
        
        stepsStackView.subviews.forEach { view in
            guard let view = view as? NewRecipeStepView else { return }
            
            if let stepViewDescription = view.stepTextView.text {
                if stepViewDescription.isEmpty {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Incomplete Steps",
                                                                      message: "Please check that you completed step description field. If you left one incomplete either remove it or complete it with description!")
                    
                    return
                }
                
                steps.append(stepViewDescription)
            }
        }
    }
    
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
        
        if selectedCategories.count > 0 {
            categoriesAsString = categoriesButtonTitle
        }
        
        categoriesButton.setTitle(categoriesButtonTitle, for: .normal)
        categoriesButton.titleLabel?.textAlignment = .center
    }
    
    // MARK: - Ingredients and Steps Private Helper Functions
    
    private func addIngredientViewToStackView() {
        let ingredientView = NewRecipeIngredientView()
        
        ingredientsStackView.addArrangedSubview(ingredientView)
        
        ingredientView.delegate = self
        
        ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant + 60.0
    }

    private func addStepViewToStackView() {
        let stepView = NewRecipeStepView()
        
        stepsStackView.addArrangedSubview(stepView)
        
        stepView.delegate = self
        stepView.stepNumberLabel.text = "\(stepsStackView.subviews.count)."
        
        stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant + 80
    }
    
    // MARK: - NewRecipeIngredientView Delegate
    
    func deletePressed(fromView: NewRecipeIngredientView) {
        ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant - 60.0
        
        fromView.removeFromSuperview()
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
    
    func deletedPressed(fromView view: NewRecipeStepView) {
        stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant - 80
            
        view.removeFromSuperview()
        
        stepsStackView.subviews.forEach { stepView in
            guard let stepView = stepView as? NewRecipeStepView,
                let stepViewIndex = stepsStackView.subviews.firstIndex(of: stepView) else { return }
            
            stepView.stepNumberLabel.text = "\(stepViewIndex + 1)."
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
        self.dificulty = dificulty
        
        dificultyButton.setTitle(dificulty, for: .normal)
    }
    
    // MARK: - Last Cook Picker Date delegate
    
    func didSelectLastCookDate(date: Date) {
        let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
        lastCookDateString = dateString
        
        lastCookButton.setTitle(dateString, for: .normal)
    }
    
    // MARK: - Categories View delegate
    
    func didSelectCategories(categories: [RecipeCategories]) {
        selectedCategories = categories
        
        configureCategoriesButton()
    }
}
