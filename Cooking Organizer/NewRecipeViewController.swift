//
//  NewRecipeViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import Firebase

class NewRecipeViewController: UIViewController, CookingTimePickerViewDelegate, DificultyPickerViewDelegate, LastCookDatePickerViewDelegate, CategoriesViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, IngredientsViewDelegate, StepsViewDelegate {
    
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
    
    var ingrdsView: IngredientsView?
    
    @IBOutlet weak var ingredientsViewHeightConstraint: NSLayoutConstraint!
    
    private var ingredients = [NewRecipeIngredient]()
    
    // MARK: - Steps View
    @IBOutlet weak var stepsView: UIView!
    @IBOutlet weak var stepsStackView: UIStackView!
    
    var stpsView: StepsView?
    
    @IBOutlet weak var stepsViewHeightConstraint: NSLayoutConstraint!
    
    private var steps = [String]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: - IBActions
    
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
                                "imageData": imageData.base64EncodedString(),
                                "portions": portionsNumber,
                                "cookingTime": cookingTime,
                                "dificulty": dificulty,
                                "lastCook": lastCookDateString ?? [],
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
    
    private func areRecipeIngredientsValid(completion: @escaping (Bool) -> Void) {
        if let ingrdsView = ingrdsView {
            ingrdsView.validateChangedIngredients { failed in
                if failed {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self, title: "Incomplete Ingredients", message: "Make sure that all ingredients' details are completed")
                } else {
                    self.ingredients = ingrdsView.ingredientsCopy
                }
                
                completion(!failed)
            }
        }
    }
    
    private func areStepsValid(completion: @escaping (Bool) -> Void) {
        if let stpsView = stpsView {
            stpsView.validateChangedSteps { failed in
                if failed {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self, title: "Steps Ingredients", message: "Make sure that all steps' details are completed")
                } else {
                    self.steps = stpsView.stepsCopy
                }
                
                completion(!failed)
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
        
        ingrdsView = IngredientsView(frame: CGRect(x: 0, y: 0, width: ingredientsStackView.frame.width, height: 0))
        
        if let ingrdsView = ingrdsView {
            ingrdsView.setEditMode(editMode: true)
            ingrdsView.delegate = self
            
            ingredientsStackView.addArrangedSubview(ingrdsView)
            
            ingredientsViewHeightConstraint.constant = 76.0
            
            ingrdsView.addIngredientButton.addTarget(self, action: #selector(addNewIngredientPressed), for: .touchUpInside)
        }
        
        stpsView = StepsView(frame: CGRect(x: 0, y: 0, width: ingredientsStackView.frame.width, height: 0))
        
        if let stpsView = stpsView {
            stpsView.setEditMode(editMode: true)
            stpsView.delegate = self
            
            stepsStackView.addArrangedSubview(stpsView)
            
            stepsViewHeightConstraint.constant = 76.0
            
            stpsView.addStepButton.addTarget(self, action: #selector(addNewStepPressed), for: .touchUpInside)
        }
    }
    
    func ingredientDeleted() {
        ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant - 60.0
    }
    
    @objc
    func addNewIngredientPressed() {
        ingredientsViewHeightConstraint.constant = ingredientsViewHeightConstraint.constant + 60.0
    }
    
    func stepDeleted() {
        stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant - 60.0
    }
    
    @objc
    func addNewStepPressed() {
        stepsViewHeightConstraint.constant = stepsViewHeightConstraint.constant + 60.0
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
    
    // MARK: - Categories View delegate
    
    func didSelectCategories(categories: [RecipeCategories]) {
        selectedCategories = categories
        
        configureCategoriesButton()
    }
}
