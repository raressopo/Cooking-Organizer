//
//  NewRecipeViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

class NewRecipeViewController: UIViewController,
                               UIImagePickerControllerDelegate,
                               UINavigationControllerDelegate {
    
    // MARK: - Recipe Name View
    @IBOutlet weak var addRecipeImage: UIButton!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var cookingTimeButton: UIButton!
    @IBOutlet weak var portionsTextField: UITextField!
    @IBOutlet weak var clearImageButton: UIButton!
    
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
    @IBOutlet var ingredientsView: IngredientsView!
    @IBOutlet weak var ingredientsStackView: UIStackView!
    
    @IBOutlet var ingredientsViewHeightConstraint: NSLayoutConstraint!
    
    private var ingredients = [NewRecipeIngredient]()
    
    // MARK: - Steps View
    
    @IBOutlet var stepsView: StepsView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    @IBOutlet var stepsViewHeightConstraint: NSLayoutConstraint!
    
    private var steps = [String]()
    
    var isKeyboardDisplayed = false
    var stepExtendedTextView = StepExtendedTextView()
    var selectedIngredientIndex = -1
    
    @IBOutlet var scrollView: UIScrollView!
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: - IBActions
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func clearImagePressed(_ sender: Any) {
        recipeImageView.image = nil
        
        clearImageButton.isHidden = true
        addRecipeImage.setTitle("Add Photo", for: .normal)
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
        let categoriesView = RecipeCategoriesView()
        
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
        guard let recipeName = recipeNameTextField.text,
            !recipeName.isEmpty else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Invalid Recipe Name",
                                                              message: "Make sure you entered a Recipe Name!")

            return
        }

        guard let portionsString = portionsTextField.text,
            let portionsNumber = NumberFormatter().number(from: portionsString) else {
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

        guard let selectedCategoriesString = categoriesAsString else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Categories Unavailable",
                                                              message: "Please check that you selected at least one category!")
            
            return
        }
        
        areRecipeIngredientsValid { valid in
            if valid {
                if self.ingredients.count == 0 {
                    self.ingredientsViewHeightConstraint.constant = 76.0
                    
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Ingredients Unavailable",
                                                                      message: "Please check that you add at least one ingredient!")
                    
                    return
                }
            } else {
                return
            }
        }
        
        areStepsValid { valid in
            if valid {
                if self.steps.count == 0 {
                    self.stepsViewHeightConstraint.constant = 76.0
                    
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Steps Unavailable",
                                                                      message: "Please check that you add at least one step!")
                    
                    return
                }
            } else {
                return
            }
        }
        
        let id = UUID().uuidString
        
        let recipeDictionary = ["name": recipeName,
                                "imageData": recipeImageView.image?.jpegData(compressionQuality: 0.0)?.base64EncodedString() ?? "",
                                "portions": portionsNumber,
                                "cookingTime": cookingTime,
                                "dificulty": dificulty,
                                "categories": selectedCategoriesString,
                                "ingredients": createIngredientsDictionary(),
                                "steps": createStepsDictionary(),
                                "cookingDates": lastCookDateString != nil ? [lastCookDateString!] : [],
                                "id": id] as [String: Any]
        
        guard let loggedInUserId = UsersManager.shared.currentLoggedInUser?.loginData.id else { return }

        Database.database().reference().child("usersData")
            .child(loggedInUserId)
            .child("recipes")
            .child(id)
            .setValue(recipeDictionary) { (error, _) in
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
        
        ingredientsViewSetup()
        stepsViewSetup()
    }
    
    @objc
    func addNewIngredientPressed() {
        ingredientsViewHeightConstraint.constant += 60.0
    }
    
    @objc
    func addNewStepPressed() {
        stepsViewHeightConstraint.constant += 60.0
    }
    
    // MARK: - UIImagePickerController delegate
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            recipeImageView.image = image
            
            addRecipeImage.setTitle("Change Photo", for: .normal)
            clearImageButton.isHidden = false
            
            picker.dismiss(animated: true, completion: nil)
        } else {
            print("Something went wrong")
        }
    }
}

// MARK: - Keyboard handlers

extension NewRecipeViewController {
    override func keyboardWillAppear(_ notification: Notification) {
        if selectedIngredientIndex >= 0 {
            scrollView.isScrollEnabled = true
            let info = notification.userInfo!
            let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height - 40, right: 0.0)
            
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize!.height
            
            if !aRect.contains(CGPoint(x: 8, y: 288 + (selectedIngredientIndex + 1) * 60)) {
                scrollView.scrollRectToVisible(CGRect(x: 8, y: 288 + (selectedIngredientIndex + 1) * 60, width: 374, height: 60), animated: true)
            }
        } else if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            if !isKeyboardDisplayed {
                stepExtendedTextView.topConstraint.constant = 40
                stepExtendedTextView.bottomConstraint.constant = keyboardHeight + 40
                
                isKeyboardDisplayed = true
            }
        }
    }
    
    override func keyboardWillDisappear(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        isKeyboardDisplayed = false
        selectedIngredientIndex = -1
    }
}

// MARK: - Cooking Time Picker

extension NewRecipeViewController: CookingTimePickerViewDelegate {
    func didSelectTime(hours: Int, minutes: Int) {
        cookingTimeHours = hours
        cookingTimeMinutes = minutes
        
        cookingTimeButton.setTitle("\(hours) hours \(minutes) minutes", for: .normal)
    }
}

// MARK: - Dificulty Picker

extension NewRecipeViewController: DificultyPickerViewDelegate {
    func didSelectDificulty(dificulty: String) {
        self.dificulty = dificulty
        
        dificultyButton.setTitle(dificulty, for: .normal)
    }
}

// MARK: - Last Cooked Date Picker

extension NewRecipeViewController: LastCookDatePickerViewDelegate {
    func didSelectLastCookDate(date: Date?) {
        if let date = date {
            let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
            lastCookDateString = dateString
        
            lastCookButton.setTitle(dateString, for: .normal)
        } else {
            lastCookDateString = nil
            
            lastCookButton.setTitle("Never Cooked", for: .normal)
        }
    }
}

// MARK: - Categories View

extension NewRecipeViewController: CategoriesViewDelegate {
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
                    categoriesButtonTitle += "\(category.string)"
                } else {
                    categoriesButtonTitle += "\(category.string), "
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

// MARK: - Ingredients View

extension NewRecipeViewController: IngredientsViewDelegate {
    func ingredientDeleted() {
        ingredientsViewHeightConstraint.constant -= 60.0
    }
    
    func ingredientTextFieldSelected(withIndex index: Int) {
        selectedIngredientIndex = index
    }
    
    private func areRecipeIngredientsValid(completion: @escaping (Bool) -> Void) {
        ingredientsView.validateChangedIngredients { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Ingredients",
                                                                  message: "Make sure that all ingredients' details are completed")
            } else {
                self.ingredients = self.ingredientsView.ingredientsCopy
            }
            
            completion(!failed)
        }
    }
    
    private func createIngredientsDictionary() -> [String: Any] {
        var ingredientsDictionary = [String: Any]()
        
        ingredients.forEach { ingredientsDictionary["\(ingredients.firstIndex(of: $0) ?? 0)"] = $0.asDictionary() }
        
        return ingredientsDictionary
    }
    
    private func ingredientsViewSetup() {
        ingredientsView.setEditMode(editMode: true)
        ingredientsView.delegate = self
        
        ingredientsViewHeightConstraint.constant = 76.0
        ingredientsViewHeightConstraint.isActive = true
            
        ingredientsView.addIngredientButton.addTarget(self, action: #selector(addNewIngredientPressed), for: .touchUpInside)
    }
}

// MARK: - Steps View

extension NewRecipeViewController: StepsViewDelegate, StepExtendedTextViewDelegate {
    func stepDetailsSaved(withText text: String?, atIndex index: Int) {
        stepsView.stepsCopy[index] = text ?? ""
            
        stepsView.tableView.reloadData()
    }
    
    func stepDeleted() {
        stepsViewHeightConstraint.constant -= 60.0
    }
    
    func stepDetailFieldPressed(withText text: String?, atIndex index: Int) {
        stepExtendedTextView = StepExtendedTextView()
        
        view.addSubview(stepExtendedTextView)
        
        stepExtendedTextView.delegate = self
        
        stepExtendedTextView.becomeFirstResponder()
        stepExtendedTextView.translatesAutoresizingMaskIntoConstraints = false
        stepExtendedTextView.stepDetailsTextView.text = text
        stepExtendedTextView.index = index
        
        NSLayoutConstraint.activate([stepExtendedTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     stepExtendedTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     stepExtendedTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     stepExtendedTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    private func areStepsValid(completion: @escaping (Bool) -> Void) {
        stepsView.validateChangedSteps { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Steps Ingredients",
                                                                  message: "Make sure that all steps' details are completed")
            } else {
                self.steps = self.stepsView.stepsCopy
            }
            
            completion(!failed)
        }
    }
    
    private func createStepsDictionary() -> [String: Any] {
        var stepsDictionary = [String: Any]()
        
        steps.forEach { stepsDictionary["\(steps.firstIndex(of: $0) ?? 0)"] = $0 }
        
        return stepsDictionary
    }
    
    private func stepsViewSetup() {
        stepsView.setEditMode(editMode: true)
        stepsView.delegate = self
        
        stepsViewHeightConstraint.constant = 76.0
        stepsViewHeightConstraint.isActive = true
            
        stepsView.addStepButton.addTarget(self, action: #selector(addNewStepPressed), for: .touchUpInside)
    }
}
