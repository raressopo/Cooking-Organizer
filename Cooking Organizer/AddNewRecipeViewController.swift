//
//  AddNewRecipeTableViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 11/04/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

enum NewRecipeSection: String, CaseIterable {
    case name = "Recipe Name"
    case portions = "Portions"
    case cookingTime = "Cooking Time"
    case difficulty = "Difficulty"
    case lastCook = "Last Cook"
    case categories = "Categories"
    case photo = "Photo"
    
    func sectionIndex() -> Int {
        switch self {
        case .name:
            return 0
        case .portions:
            return 1
        case .cookingTime:
            return 2
        case .difficulty:
            return 3
        case .lastCook:
            return 4
        case .categories:
            return 5
        case .photo:
            return 6
        }
      }
}

import Foundation

class AddNewRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// Recipe Name
    private var recipeName: String?
    /// Portions
    private var portionsAsString: String?
    /// Cooking Time
    private var cookingTimeHours = 0
    private var cookingTimeMinutes = 0
    /// Difficulty
    private var difficulty: String?
    /// Last Cook
    private var lastCookDateString: String?
    /// Categories
    private var selectedCategories = [RecipeCategories]()
    private var categoriesAsString: String?
    /// Photo
    private var recipePhoto: UIImage?
    /// Ingredients
    private var ingredients = [NewRecipeIngredient]()
    /// Steps
    private var steps = [String]()
    
    @IBOutlet weak var buttonsView: UIView! {
        didSet {
            buttonsView.clipsToBounds = true
            buttonsView.layer.cornerRadius = 24.0
            buttonsView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            buttonsView.layer.borderWidth = 2.0
            buttonsView.layer.borderColor = UIColor.buttonTitleColor().cgColor
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.hexStringToUIColor(hex: "#024B3C")
        
        self.hideKeyboardWhenTappedAround()
        
        self.navigationItem.title = "Add New Recipe"
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
        if segue.identifier == "newRecipeIngredientsSegue", let destinationVC = segue.destination as? IngredientsViewController {
            destinationVC.createRecipeMode = true
            destinationVC.createRecipeIngredients = ingredients
            destinationVC.delegate = self
        } else if segue.identifier == "newRecipeStepsSegue", let destinationVC = segue.destination as? StepsViewController {
            destinationVC.createRecipeMode = true
            destinationVC.createRecipeSteps = steps
            destinationVC.delegate = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewRecipeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == section }) {
            if section == .portions {
                return 0
            } else if section == .photo, self.recipePhoto == nil {
                return 0
            }
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == indexPath.section }) {
            switch section {
            case .name:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as? AddChangeRecipeTextFieldCell else {
                    fatalError()
                }
                
                cell.textField.delegate = cell
                cell.section = .name
                cell.delegate = self
                cell.selectionStyle = .none
                
                return cell
            case .photo:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell") as? AddChangeRecipeImageCell else {
                    fatalError()
                }
                
                if let recipePhoto = self.recipePhoto {
                    cell.recipeImageView.isHidden = false
                    cell.recipeImageView.image = recipePhoto
                    cell.removeImageButton.isHidden = false
                    
                    cell.removeImageButton.addTarget(self, action: #selector(removeSelectedPhotoPressed), for: .touchUpInside)
                } else {
                    cell.recipeImageView.isHidden = true
                    cell.recipeImageView.image = nil
                    cell.removeImageButton.isHidden = true
                }
                
                cell.selectionStyle = .none
                
                return cell
            default:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "textViewCell") as? AddChangeRecipeTextViewCell else {
                    fatalError()
                }
                
                switch section {
                case .cookingTime:
                    if self.cookingTimeMinutes == 0 && self.cookingTimeHours == 0 {
                        cell.textView.text = "• No cooking time added"
                    } else {
                        var formattedDuration = ""
                        
                        if self.cookingTimeHours > 0 && self.cookingTimeMinutes == 0 {
                            formattedDuration = "\(self.cookingTimeHours) hours"
                        } else if self.cookingTimeHours == 0 && self.cookingTimeMinutes > 0 {
                            formattedDuration = "\(self.cookingTimeMinutes) minutes"
                        } else {
                            formattedDuration = "\(self.cookingTimeHours) hours \(self.cookingTimeMinutes) minutes"
                        }
                        
                        cell.textView.text = "• \(formattedDuration)"
                    }
                case .difficulty:
                    if let difficulty = self.difficulty {
                        cell.textView.text = "• \(difficulty)"
                    } else {
                        cell.textView.text = "• No difficulty added"
                    }
                case .lastCook:
                    if let lastCookDateString = self.lastCookDateString {
                        cell.textView.text = "• \(lastCookDateString)"
                    } else {
                        cell.textView.text = "• Never cooked"
                    }
                case .categories:
                    if let categoriesAsString = self.categoriesAsString {
                        cell.textView.text = "• \(categoriesAsString)"
                    } else {
                        cell.textView.text = "• No categories selected"
                    }
                default:
                    break
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "textViewdCell") as? AddChangeRecipeTextViewCell else {
                fatalError()
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == section }) {
            let headerView = NewRecipeSectionHeaderView(withFrame: CGRect(x: 10,
                                                                          y: 0,
                                                                          width: self.tableView.frame.width - 32,
                                                                          height: section == .some(.portions) ? 50.0 : 40.0))
            
            var shouldHaveAddButton = true
            
            switch section {
            case .cookingTime:
                if self.cookingTimeHours != 0 || self.cookingTimeMinutes != 0 {
                    shouldHaveAddButton = false
                }
                
                headerView.changeAddButton.addTarget(self,
                                                     action: #selector(changeAddCookingTimePressed),
                                                     for: .touchUpInside)
            case .difficulty:
                if self.difficulty != nil {
                    shouldHaveAddButton = false
                }
                
                headerView.changeAddButton.addTarget(self,
                                                     action: #selector(changeAddDifficultyButtonPressed),
                                                     for: .touchUpInside)
            case .lastCook:
                if self.lastCookDateString != nil {
                    shouldHaveAddButton = false
                }
                
                headerView.changeAddButton.addTarget(self,
                                                     action: #selector(changeAddLastCookButonPressed),
                                                     for: .touchUpInside)
            case .categories:
                if self.selectedCategories.count > 0 {
                    shouldHaveAddButton = false
                }
                
                headerView.changeAddButton.addTarget(self,
                                                     action: #selector(changeAddCategoriesButonPressed),
                                                     for: .touchUpInside)
            case .photo:
                if let _ = self.recipePhoto {
                    shouldHaveAddButton = false
                }
                
                headerView.changeAddButton.addTarget(self,
                                                     action: #selector(changeAddPhotoButonPressed),
                                                     for: .touchUpInside)
            default:
                break
            }
            
            headerView.configure(withNewRecipeSection: section, andDelegate: self, withAddButton: shouldHaveAddButton)
            
            let containerHeaderView = UIView(frame: CGRect(x: 0,
                                                           y: 0,
                                                           width: self.tableView.frame.width,
                                                           height: section == .some(.portions) ? 50.0 : 40.0))
            containerHeaderView.backgroundColor = UIColor.hexStringToUIColor(hex: "#024B3C")
            containerHeaderView.addSubview(headerView)
            
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.clipsToBounds = true
            headerView.layer.cornerRadius = 16.0
            
            if section == .photo, self.recipePhoto == nil {
                headerView.layer.cornerRadius = 16.0
            } else if section != .portions {
                headerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            }
            
            NSLayoutConstraint.activate([headerView.centerYAnchor.constraint(equalTo: containerHeaderView.centerYAnchor), headerView.centerXAnchor.constraint(equalTo: containerHeaderView.centerXAnchor), headerView.widthAnchor.constraint(equalToConstant: self.tableView.frame.width - 32), headerView.topAnchor.constraint(equalTo: containerHeaderView.topAnchor), headerView.bottomAnchor.constraint(equalTo: containerHeaderView.bottomAnchor)])
            return containerHeaderView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "#024B3C")
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == NewRecipeSection.portions.sectionIndex() {
            return 50.0
        } else {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == indexPath.section }) {
            if section == .photo, self.recipePhoto != nil {
                return 215
            } else if section == .name {
                return 65
            }
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    @objc func changeAddCookingTimePressed() {
        let cookingTimePickerView = CookingTimePickerView()
        
        cookingTimePickerView.delegate = self
        
        cookingTimePickerView.hoursSelected = cookingTimeHours
        cookingTimePickerView.minutesSelected = cookingTimeMinutes
        
        self.view.addSubview(cookingTimePickerView)
        
        cookingTimePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([cookingTimePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     cookingTimePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     cookingTimePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     cookingTimePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @objc func changeAddDifficultyButtonPressed() {
        let dificultyPickerView = DificultyPickerView()
        
        dificultyPickerView.delegate = self
        
        view.addSubview(dificultyPickerView)
        
        dificultyPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([dificultyPickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     dificultyPickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     dificultyPickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     dificultyPickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @objc func changeAddLastCookButonPressed() {
        let lastCookDatePickerView = LastCookDatePickerView()
        
        lastCookDatePickerView.delegate = self
        
        view.addSubview(lastCookDatePickerView)
        
        lastCookDatePickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([lastCookDatePickerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     lastCookDatePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     lastCookDatePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     lastCookDatePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @objc func changeAddCategoriesButonPressed() {
        let categoriesView = RecipeCategoriesView()
        
        categoriesView.copyOfSelectedCategories = self.selectedCategories
        categoriesView.delegate = self
        
        view.addSubview(categoriesView)
        
        categoriesView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([categoriesView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     categoriesView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     categoriesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     categoriesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    @objc func changeAddPhotoButonPressed() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    @objc func removeSelectedPhotoPressed() {
        self.recipePhoto = nil
        
        self.tableView.reloadData()
    }
    
    @IBAction func addRecipePressed(_ sender: Any) {
        guard let recipeName = self.recipeName, recipeName.isEmpty == false else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Invalid Recipe Name",
                                                              message: "Make sure you entered a Recipe Name!")

            return
        }
        
        guard let categoriesAsString = self.categoriesAsString, categoriesAsString.isEmpty == false else {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Categories Unavailable",
                                                              message: "Please check that you selected at least one category!")
            
            return
        }
        
        let newRecipeID = UUID().uuidString
        
        let newRecipe = NewRecipe(recipeName: recipeName,
                                  portionsAsString: self.portionsAsString,
                                  cookingTimeHours: self.cookingTimeHours,
                                  cookingTimeMinutes: self.cookingTimeMinutes,
                                  difficulty: self.difficulty,
                                  lastCookDateString: self.lastCookDateString,
                                  categoriesAsString: categoriesAsString,
                                  recipePhoto: self.recipePhoto,
                                  ingredients: self.ingredients,
                                  steps: self.steps,
                                  id: newRecipeID)
        
        FirebaseRecipesService.shared.addRecipe(withRecipeDictionary: newRecipe.asDictionary(), andID: newRecipeID) {
            self.navigationController?.popViewController(animated: true)
        } failure: {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Recipe Adding Failed",
                                                              message: "Something went wrong ")
        }
    }
}

extension AddNewRecipeViewController: AddChangeRecipeTextFieldCellDelegate {
    
    func textFieldDidChanged(forSection section: NewRecipeSection, andText text: String) {
        switch section {
        case .name:
            self.recipeName = text
        default:
            break
        }
    }
    
}

extension AddNewRecipeViewController: NewRecipeSectionHeaderViewDelegate {
    
    func textFieldDidChanged(forSectionHeader section: NewRecipeSection, andText text: String) {
        switch section {
        case .portions:
            self.portionsAsString = text
        default:
            break
        }
    }
    
}

extension AddNewRecipeViewController: CookingTimePickerViewDelegate {
    
    func didSelectTime(hours: Int, minutes: Int) {
        self.cookingTimeHours = hours
        self.cookingTimeMinutes = minutes
        
        self.tableView.reloadSections([NewRecipeSection.cookingTime.sectionIndex()], with: .none)
    }
    
}

extension AddNewRecipeViewController: DificultyPickerViewDelegate {
    
    func didSelectDificulty(dificulty: String) {
        self.difficulty = dificulty
        
        self.tableView.reloadSections([NewRecipeSection.difficulty.sectionIndex()], with: .automatic)
    }
    
}

extension AddNewRecipeViewController: LastCookDatePickerViewDelegate {
    
    func didSelectLastCookDate(date: Date?) {
        if let date = date {
            let dateString = UtilsManager.shared.dateFormatter.string(from: date)
        
            lastCookDateString = dateString
        } else {
            lastCookDateString = nil
        }
        
        self.tableView.reloadSections([NewRecipeSection.lastCook.sectionIndex()], with: .automatic)
    }
    
}

extension AddNewRecipeViewController: CategoriesViewDelegate {
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
        
        self.tableView.reloadSections([NewRecipeSection.categories.sectionIndex()], with: .automatic)
    }
}

// MARK: - ImagePicker Delegate

extension AddNewRecipeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.recipePhoto = image
            
            picker.dismiss(animated: true, completion: nil)
            
            self.tableView.reloadData()
            
            let indexPath = IndexPath(item: 0, section: NewRecipeSection.photo.sectionIndex())
            
            self.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
        } else {
            print("Something went wrong")
        }
    }
    
}

extension AddNewRecipeViewController: CreateRecipeIngredientsProtocol {
    
    func ingredientsAdded(ingredients: [NewRecipeIngredient]) {
        self.ingredients = ingredients
    }
    
}

extension AddNewRecipeViewController: CreateRecipeStepsProtocol {
    
    func stepsAdded(steps: [String]) {
        self.steps = steps
    }
    
}
