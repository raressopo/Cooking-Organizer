//
//  RecipeDetailsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class RecipeDetailsViewController: UIViewController {
    
    // MARK: Normal Mode Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel! {
        didSet {
            self.recipeTitle.adjustsFontSizeToFitWidth = true
            self.recipeTitle.minimumScaleFactor = 0.2
        }
    }
    @IBOutlet weak var buttonsView: UIView! {
        didSet {
            buttonsView.clipsToBounds = true
            buttonsView.layer.cornerRadius = 24.0
            buttonsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            buttonsView.layer.borderWidth = 2.0
            buttonsView.layer.borderColor = UIColor.buttonTitleColor().cgColor
        }
    }
    @IBOutlet weak var portionsLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel! {
        didSet {
            self.durationLabel.adjustsFontSizeToFitWidth = true
            self.durationLabel.minimumScaleFactor = 0.2
        }
    }
    @IBOutlet weak var lastCookLabel: UILabel! {
        didSet {
            self.lastCookLabel.adjustsFontSizeToFitWidth = true
            self.lastCookLabel.minimumScaleFactor = 0.2
        }
    }
    @IBOutlet weak var categoriesLabel: UILabel!
    
    @IBOutlet weak var removePhotoButton: UIButton! {
        didSet {
            self.removePhotoButton.layer.cornerRadius = 15.0
            self.removePhotoButton.backgroundColor = UIColor.systemBackground
            self.removePhotoButton.setTitleColor(UIColor.deleteButtonTitleColor(), for: .normal)
            self.removePhotoButton.layer.borderWidth = 2.0
            self.removePhotoButton.layer.borderColor = UIColor.deleteButtonTitleColor().cgColor
        }
    }
    @IBOutlet weak var changePhotoButton: UIButton! {
        didSet {
            self.changePhotoButton.layer.cornerRadius = 15.0
            self.changePhotoButton.backgroundColor = UIColor.systemBackground
            self.changePhotoButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            self.changePhotoButton.layer.borderWidth = 2.0
            self.changePhotoButton.layer.borderColor = UIColor.buttonTitleColor().cgColor
        }
    }

    @IBOutlet weak var editPhotoButtonsStackView: UIStackView!
    @IBOutlet weak var ingredientsAndStepsStackView: UIStackView!
    
    @IBOutlet var recipeDetailsViews: [UIView]! {
        didSet {
            self.recipeDetailsViews.forEach { view in
                view.layer.cornerRadius = 16.0
            }
        }
    }
    
    // MARK: Edit Mode Outlets
    @IBOutlet weak var recipeNameTextField: UITextField! {
        didSet {
            recipeNameTextField.configure()
        }
    }
    @IBOutlet weak var portionsTextField: UITextField! {
        didSet {
            portionsTextField.configure()
        }
    }
    @IBOutlet weak var difficultyButton: UIButton! {
        didSet {
            self.difficultyButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    @IBOutlet weak var durationButton: UIButton! {
        didSet {
            self.durationButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    @IBOutlet weak var lastCookButton: UIButton! {
        didSet {
            self.lastCookButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            self.lastCookButton.titleLabel?.adjustsFontSizeToFitWidth = true
            self.lastCookButton.titleLabel?.minimumScaleFactor = 0.2
        }
    }
    @IBOutlet weak var categoriesButton: UIButton! {
        didSet {
            self.categoriesButton.titleLabel?.numberOfLines = 10
            self.categoriesButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
            self.categoriesButton.titleLabel?.adjustsFontSizeToFitWidth = true
            self.categoriesButton.titleLabel?.minimumScaleFactor = 0.2
        }
    }
    @IBOutlet weak var ingredientsButton: UIButton! {
        didSet {
            self.ingredientsButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    @IBOutlet weak var stepsButton: UIButton! {
        didSet {
            self.stepsButton.setTitleColor(UIColor.buttonTitleColor(), for: .normal)
        }
    }
    
    @IBOutlet weak var recipeDetailsTopConstraintWithNoImage: NSLayoutConstraint!
    @IBOutlet weak var recipeDetailsTopConstraintWithImage: NSLayoutConstraint!
    
    // MARK: Normal Mode Props
    var recipe: Recipe?
    
    // MARK: Edit Mode Props
    var changedRecipe = ChangedRecipe()
    
    private var difficulty: String?
    private var cookingTimeHours = 0
    private var cookingTimeMinutes = 0
    private var cookingDateChanges: [String]?
    private var selectedCategories = [RecipeCategories]()
    private var categoriesAsString: String?
    
    // MARK: - View Lifecycle
    
    @IBOutlet weak var mainContainerView: UIView! {
        didSet {
            self.mainContainerView.backgroundColor = UIColor.screenBackground()
            self.mainContainerView.clipsToBounds = true
            self.mainContainerView.layer.cornerRadius = 24.0
            self.mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDataManager.shared.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editPressed))
        self.view.backgroundColor = UIColor.screenBackground()
        setupRecipeDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
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
        
        if let portions = recipe.portions {
            portionsLabel.text = "\(portions)"
        }
        
        if let difficulty = recipe.dificulty {
            difficultyLabel.text = "\(difficulty)"
        }
        
        if let duration = recipe.cookingTime {
            self.durationLabel.text = duration
        }
        
        if let lastCook = recipe.cookingDates?.first {
            lastCookLabel.text = lastCook
        }
        
        self.categoriesButton.isEnabled = false
        self.categoriesButton.setTitleColor(.black, for: .normal)
        self.categoriesButton.setTitle(recipe.categories ?? "Not Set", for: .normal)
    }
    
    private func setupRecipeImage() {
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        if let data = recipe.imageData, !data.isEmpty {
            let dataDecode = Data(base64Encoded: data, options: .ignoreUnknownCharacters)
            
            if let imageData = dataDecode {
                let decodedImage = UIImage(data: imageData)
                
                imageView.image = decodedImage
                
                self.mainContainerView.layer.cornerRadius = 24.0
            }
        } else {
            imageView.isHidden = true
            
            mainContainerView.layer.cornerRadius = 0.0
        }
    }
    
    private func setScreenInEditMode(editMode: Bool) {
        guard let recipe = recipe else { fatalError("recipe should exist!") }
        
        recipeTitle.isHidden = editMode
        ingredientsAndStepsStackView.isHidden = editMode
        self.editPhotoButtonsStackView.isHidden = !editMode
        
        changePhotoButton.isHidden = !editMode
        recipeNameTextField.isHidden = !editMode
        portionsTextField.isHidden = !editMode
        durationButton.isHidden = !editMode
        difficultyButton.isHidden = !editMode
        lastCookButton.isHidden = !editMode
        categoriesButton.isEnabled = editMode
        categoriesButton.setTitleColor(editMode ? UIColor.buttonTitleColor() : .black , for: .normal)
        
        if editMode {
            changedRecipe = ChangedRecipe()
            cookingDateChanges = nil
            
            imageView.isHidden = false
            
            recipeNameTextField.text = recipe.name
            
            portionsLabel.text = nil
            
            if let portions = recipe.portions {
                portionsTextField.text = "\(portions)"
            }
            
            if let lastCookingDate = recipe.cookingDates?.first {
                self.lastCookLabel.text = lastCookingDate
            }
            
            if let datesCount = recipe.cookingDates?.count, datesCount > 1 {
                self.lastCookButton.setTitle("See All Dates", for: .normal)
            }
            
            changedRecipe.cookingDates = recipe.cookingDates
        } else {
            setupRecipeDetails()
        }
    }
    
    private func changedRecipeDictionary() -> [String: Any] {
        var changedRecipeDictionary = [String: Any]()
        
        guard let recipe = recipe else { return changedRecipeDictionary }
        
        // Recipe Image
        if let originalImage = recipe.imageData,
           let changedImage = changedRecipe.imageData,
           originalImage != changedImage {
            
            changedRecipeDictionary["imageData"] = changedImage
            
            recipe.imageData = changedImage
        }
        
        // Recipe Name
        if let name = recipeNameTextField.text,
           !name.isEmpty,
           name != recipe.name {
            
            changedRecipeDictionary["name"] = name
        }
        
        // Portions
        if let portions = portionsTextField.text,
           !portions.isEmpty,
           let portionsAsNumber = NumberFormatter().number(from: portions),
           portionsAsNumber.intValue != recipe.portions {
            
            changedRecipeDictionary["portions"] = portionsAsNumber
        }
        
        // Cooking Time
        if (cookingTimeHours != 0 || cookingTimeMinutes != 0),
           "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes" != recipe.cookingTime {
            
            changedRecipeDictionary["cookingTime"] = "\(cookingTimeHours) hours \(cookingTimeMinutes) minutes"
        }
        
        // Dificulty
        if let dificulty = difficulty, dificulty != recipe.dificulty {
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
        
        return changedRecipeDictionary
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
        let changedRecipeDetails = self.changedRecipeDictionary()
        
        if let userId = UsersManager.shared.currentLoggedInUser?.loginData.id,
           let recipeId = self.recipe?.id,
           !changedRecipeDetails.isEmpty {
            
            FirebaseRecipesService.shared.updateRecipe(froUserId: userId,
                                                           andForRecipeId: recipeId,
                                                           withDetails: changedRecipeDetails) { success in
                if success {
                    self.recipe = UsersManager.shared.currentLoggedInUser!.data.recipes?[recipeId]
                    
                    self.navigationItem.hidesBackButton = false
                    self.navigationItem.leftBarButtonItem = nil
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                        target: self,
                                                                        action: #selector(self.editPressed))
                    
                    self.setScreenInEditMode(editMode: false)
                } else {
                    AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                      title: "Update Failed",
                                                                      message: "Something went wrong updating the recipe. Please try again later!")
                }
            }
        } else {
            navigationItem.hidesBackButton = false
            navigationItem.leftBarButtonItem = nil
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                                target: self,
                                                                action: #selector(editPressed))
            
            setScreenInEditMode(editMode: false)
        }
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
    
    @IBAction func removePhotoPressed(_ sender: Any) {
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
        let cookingDatesView = CookingDatesView(withFrame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: 100,
                                                                  height: 100),
                                                andCookingDates: changedRecipe.cookingDates ?? [String]())
        
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
        
        categoriesView.copyOfSelectedCategories = selectedCategories.count != 0 ? selectedCategories : (recipe?.recipeCategories ?? [RecipeCategories]())
        categoriesView.delegate = self
        
        view.addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
}

extension RecipeDetailsViewController: UserDataManagerDelegate {
    
    func recipeChanged() {
        if let userRecipes = UsersManager.shared.currentLoggedInUser?.recipes {
            recipe = userRecipes.first(where: { $0.id == recipe?.id })
        }
    }
    
}

// MARK: - Recipe Image

extension RecipeDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension RecipeDetailsViewController: DificultyPickerViewDelegate {
    
    func didSelectDificulty(dificulty: String) {
        self.difficulty = dificulty
        self.difficultyLabel.text = dificulty
    }
    
}

extension RecipeDetailsViewController: CookingTimePickerViewDelegate {
    
    func didSelectTime(hours: Int, minutes: Int) {
        self.cookingTimeHours = hours
        self.cookingTimeMinutes = minutes
        
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
        
        self.durationLabel.text = formattedDuration
    }
    
}

extension RecipeDetailsViewController: CookingDatesViewDelegate {
    
    func cokingDatesChanged(withDates dates: [String]) {
        self.cookingDateChanges = dates
        self.changedRecipe.cookingDates = dates
        
        if let count = self.cookingDateChanges?.count {
            if count == 0 {
                self.lastCookLabel.text = "Never Cooked"
                self.lastCookButton.setTitle("Change", for: .normal)
            } else if count == 1, let lastCookingDate = self.cookingDateChanges?.first {
                self.lastCookLabel.text = lastCookingDate
                self.lastCookButton.setTitle("Change", for: .normal)
            } else if let lastCookingDate = self.cookingDateChanges?.first {
                self.lastCookLabel.text = lastCookingDate
                self.lastCookButton.setTitle("See All Dates", for: .normal)
            }
        }
    }
    
}

extension RecipeDetailsViewController: CategoriesViewDelegate {
    
    func didSelectCategories(categories: [RecipeCategories]) {
        selectedCategories = categories
        
        configureCategoriesButton()
    }
    
    private func configureCategoriesButton() {
        var categoriesButtonTitle = ""
        
        if selectedCategories.count == 0 {
            categoriesButtonTitle = "Not Set"
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
    }
    
}
