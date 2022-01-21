//
//  RecipeDetailsViewControllerv2.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsViewControllerv2: UIViewController {
    
    // MARK: Normal Mode Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var portionsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var lastCookLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var ingredientsAndStepsStackView: UIStackView!
    
    // MARK: Edit Mode Outlets
    @IBOutlet weak var changePhotoButton: UIButton!
    @IBOutlet weak var recipeNameTextField: UITextField!
    @IBOutlet weak var portionsTextField: UITextField!
    @IBOutlet weak var difficultyButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var lastCookButton: UIButton!
    @IBOutlet weak var categoriesButton: UIButton!
    
    // MARK: Normal Mode Props
    var recipe: Recipe?
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleHeightConstraint: NSLayoutConstraint!
    
    // MARK: Edit Mode Props
    var changedRecipe = ChangedRecipe()
    
    private var dificulty: String?
    private var cookingTimeHours = 0
    private var cookingTimeMinutes = 0
    private var cookingDateChanges: [String]?
    private var selectedCategories = [RecipeCategories]()
    private var categoriesAsString: String?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager.shared.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editPressed))
        
        setupRecipeDetails()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ingredientsSegue", let destinationVC = segue.destination as? IngredientsViewController {
            if let recipeIngredients = recipe?.ingredients, recipeIngredients.count > 0 {
                destinationVC.ingredients = recipeIngredients
            }
            
            destinationVC.recipe = recipe
        } else if segue.identifier == "stepsSegue", let destinationVC = segue.destination as? StepsViewController {
            if let recipeSteps = recipe?.steps, recipeSteps.count > 0 {
                destinationVC.steps = recipeSteps
            }
            
            destinationVC.recipe = recipe
        }
    }
    
    // MARK: - Private helpers
    
    private func setupRecipeDetails() {
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        setupRecipeImage()
        
        recipeTitle.text = recipe.name
        portionsLabel.text = "Portions: \(recipe.portions)"
        durationLabel.text = "Duration: \(recipe.cookingTime ?? "Undefined")"
        difficultyLabel.text = "Difficulty: \(recipe.dificulty ?? "Undefined")"
        lastCookLabel.text = "Last Cook: \(recipe.cookingDates?.first ?? "Undefined")"
        categoriesLabel.text = "Categries: \(recipe.categories ?? "Undefined")"
        
        titleHeightConstraint.constant = recipeTitle.text?.size(for: recipeTitle).height ?? titleHeightConstraint.constant
    }
    
    private func setupRecipeImage() {
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        if let data = recipe.imageData, !data.isEmpty {
            let dataDecode = Data(base64Encoded: data, options: .ignoreUnknownCharacters)
            
            if let imageData = dataDecode {
                let decodedImage = UIImage(data: imageData)
                
                imageView.image = decodedImage
            }
        } else {
            imageView.isHidden = true
            
            titleTopConstraint.constant = titleTopConstraint.constant - imageView.frame.height
        }
    }
    
    private func setScreenInEditMode(editMode: Bool) {
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        recipeTitle.isHidden = editMode
        ingredientsAndStepsStackView.isHidden = editMode
        
        changePhotoButton.isHidden = !editMode
        recipeNameTextField.isHidden = !editMode
        portionsTextField.isHidden = !editMode
        durationButton.isHidden = !editMode
        difficultyButton.isHidden = !editMode
        lastCookButton.isHidden = !editMode
        categoriesButton.isHidden = !editMode
        
        if editMode {
            changedRecipe = ChangedRecipe()
            cookingDateChanges = nil
            
            imageView.isHidden = false
            
            titleHeightConstraint.constant = 36
            titleTopConstraint.constant = 20
            
            recipeNameTextField.text = recipe.name
            
            portionsLabel.text = "Portions:"
            portionsTextField.text = "\(recipe.portions)"
            
            durationLabel.text = "Duration:"
            durationButton.setTitle(recipe.formattedCookingTime, for: .normal)
            durationButton.contentHorizontalAlignment = .right
            
            difficultyLabel.text = "Difficulty:"
            difficultyButton.setTitle(recipe.dificulty, for: .normal)
            difficultyButton.contentHorizontalAlignment = .right
            
            lastCookLabel.text = "Last Cook:"
            lastCookButton.setTitle(recipe.cookingDates?.first ?? "Never Cooked", for: .normal)
            lastCookButton.contentHorizontalAlignment = .right
            
            categoriesLabel.text = "Categries:"
            categoriesButton.setTitle(recipe.categories, for: .normal)
            categoriesButton.contentHorizontalAlignment = .right
        } else {
            setupRecipeDetails()
        }
    }
    
    // MARK: - Selectors
    
    @objc private func editPressed() {
        navigationItem.hidesBackButton = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(savePressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelPressed))
        
        setScreenInEditMode(editMode: true)
    }
    
    @objc private func savePressed() {
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editPressed))
        
        setScreenInEditMode(editMode: false)
    }
    
    @objc private func cancelPressed() {
        navigationItem.hidesBackButton = false
        navigationItem.leftBarButtonItem = nil
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editPressed))
        
        setScreenInEditMode(editMode: false)
    }
    
    // MARK: - Actions
    
    @IBAction func changePhotoPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func difficultyPressed(_ sender: Any) {
        let dificultyPickerView = DificultyPickerView()
        
        dificultyPickerView.delegate = self
        
        view.addSubview(dificultyPickerView)
        
        dificultyPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([dificultyPickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     dificultyPickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     dificultyPickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     dificultyPickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func durationPressed(_ sender: Any) {
        let cookingTimePickerView = CookingTimePickerView()
        
        cookingTimePickerView.delegate = self
        
        self.view.addSubview(cookingTimePickerView)
        
        cookingTimePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([cookingTimePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     cookingTimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     cookingTimePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     cookingTimePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @IBAction func lastCookPressed(_ sender: Any) {
        let cookingDatesView = CookingDatesView(withFrame: CGRect(x: 0, y: 0, width: 100, height: 100), andCookingDates: recipe?.cookingDates ?? [String]())
        
        cookingDatesView.delegate = self
        
        view.addSubview(cookingDatesView)
        
        cookingDatesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([cookingDatesView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     cookingDatesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     cookingDatesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     cookingDatesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
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
    
}

extension RecipeDetailsViewControllerv2: UserDataManagerDelegate {
    
    func recipeChanged() {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipe = userRecipes.first(where: { $0.id == recipe?.id })
        }
    }
    
}

// MARK: - Recipe Image

extension RecipeDetailsViewControllerv2: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let imageData = UtilsManager.resizeImageTo450x450AsData(image: image) {
                changedRecipe.imageData = imageData.base64EncodedString()
                
                imageView.image = image
            }
            
            picker.dismiss(animated: true, completion: nil)
        } else {
            print("Something went wrong")
        }
    }
    
}

extension RecipeDetailsViewControllerv2: DificultyPickerViewDelegate {
    
    func didSelectDificulty(dificulty: String) {
        self.dificulty = dificulty
        
        difficultyButton.setTitle(dificulty, for: .normal)
    }
    
}

extension RecipeDetailsViewControllerv2: CookingTimePickerViewDelegate {
    
    func didSelectTime(hours: Int, minutes: Int) {
        cookingTimeHours = hours
        cookingTimeMinutes = minutes
        
        var formattedDuration = ""
        
        if hours > 0 && minutes == 0 {
            formattedDuration = "\(hours) hours"
        } else if hours == 0 && minutes > 0 {
            formattedDuration = "\(minutes) minutes"
        } else  if hours == 0, minutes == 0 {
            formattedDuration = "Not Defined"
        } else {
            formattedDuration = "\(hours) hours \(minutes) minutes"
        }
        
        durationButton.setTitle(formattedDuration, for: .normal)
    }
    
}

extension RecipeDetailsViewControllerv2: CookingDatesViewDelegate {
    
    func cokingDatesChanged(withDates dates: [String]) {
        cookingDateChanges = dates
        
        lastCookButton.setTitle(cookingDateChanges != nil ? "See Cooking Dates" : "Never Cooked", for: .normal)
    }
    
}

extension RecipeDetailsViewControllerv2: CategoriesViewDelegate {
    
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
