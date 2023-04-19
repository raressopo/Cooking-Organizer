//
//  StepsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

protocol CreateRecipeStepsProtocol: AnyObject {
    func stepsAdded(steps: [String])
}

class StepsViewController: UIViewController {
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var addStepButton: UIButton! {
        didSet {
            self.addStepButton.setTitleColor(UIColor.hexStringToUIColor(hex: "#C17A03"), for: .normal)
            self.addStepButton.titleLabel?.font = UIFont(name: "Proxima Nova Alt Bold", size: 21.0)
        }
    }
    
    @IBOutlet weak var noStepsAddedLabel: UILabel! {
        didSet {
            self.noStepsAddedLabel.font = UIFont(name: "Proxima Nova Alt Light Italic", size: 24.0)
        }
    }
    
    @IBOutlet weak var stepsTableViewBottomToButtonConstraint: NSLayoutConstraint!
    
    var stepsTableViewBottomToScreenBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var addStepButtonBottomConstraint: NSLayoutConstraint!
    
    lazy var steps = [String]()
    lazy var stepsCopy = [String]()
    lazy var createRecipeSteps = [String]()
    
    var recipe: Recipe?
    
    var createRecipeMode = false
    
    weak var delegate: CreateRecipeStepsProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        
        stepsTableView.register(UINib(nibName: "RecipeStepCell", bundle: nil), forCellReuseIdentifier: "stepCell")
        stepsTableView.register(UINib(nibName: "ChangeRecipeStepCell", bundle: nil), forCellReuseIdentifier: "changeStepCell")
        
        if createRecipeMode {
            let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
            editNavBarButton.tintColor = UIColor.hexStringToUIColor(hex: "#C17A03")
            
            self.navigationItem.hidesBackButton = true
            self.navigationItem.rightBarButtonItem = editNavBarButton
            
            stepsTableView.setEditing(true, animated: false)
        } else {
            stepsTableViewBottomToButtonConstraint.isActive = false
            addStepButton.isHidden = true
            
            stepsTableViewBottomToScreenBottomConstraint = stepsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            stepsTableViewBottomToScreenBottomConstraint?.isActive = true
            
            let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
            
            self.navigationItem.rightBarButtonItem = editNavBarButton
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        self.stepsTableView.keyboardDismissMode = .onDrag
        
        self.view.backgroundColor = UIColor.hexStringToUIColor(hex: "#024B3C")
        
        if (createRecipeMode && self.createRecipeSteps.count > 0) ||
            (self.stepsTableView.isEditing && self.stepsCopy.count > 0) ||
            (self.steps.count > 0) {
            self.noStepsAddedLabel.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func addStepPressed(_ sender: Any) {
        let step = String()
        
        if createRecipeMode {
            createRecipeSteps.append(step)
        } else {
            stepsCopy.append(step)
        }
        
        self.noStepsAddedLabel.isHidden = true
        
        stepsTableView.reloadData()
    }
    
    @objc private func donePressed() {
        validateChangedSteps { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Steps",
                                                                  message: "Please complete all the info for all the steps you have or added.")
            } else {
                self.delegate?.stepsAdded(steps: self.createRecipeSteps)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func editPressed() {
        setEditMode(editMode: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(savePressed))
        self.navigationItem.hidesBackButton = true
    }
    
    @objc func savePressed() {
        validateChangedSteps(validationFailed: { failed in
            if failed {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Incomplete Steps",
                                                                  message: "Please make sure that you completed all steps details")
                
                return
            } else {
                var changedSteps = [String:Any]()
                
                if self.areStepsChanged() {
                    self.stepsCopy.forEach { changedSteps["\(self.stepsCopy.firstIndex(of: $0) ?? 0)"] = $0 }
                } else {
                    self.setEditMode(editMode: false)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                    self.navigationItem.hidesBackButton = false
                    
                    return
                }
                
                if let userId = UsersManager.shared.currentLoggedInUser?.loginData.id,
                    let recipeId = self.recipe?.id {
                    
                    FirebaseRecipesService.shared.updateRecipe(froUserId: userId,
                                                                   andForRecipeId: recipeId,
                                                                   withDetails: ["steps":changedSteps]) { success in
                                                                    if success {
                                                                        self.recipe = UsersManager.shared.currentLoggedInUser!.data.recipes?[recipeId]
                                                                        
                                                                        self.refreshSteps()
                                                                        
                                                                        self.setEditMode(editMode: false)
                                                                        
                                                                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                                                                        self.navigationItem.hidesBackButton = false
                                                                    } else {
                                                                        AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                                                                          title: "Update Failed",
                                                                                                                          message: "Something went wrong updating the recipe. Please try again later!")
                                                                    }
                    }
                } else {
                    self.setEditMode(editMode: false)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editPressed))
                    self.navigationItem.hidesBackButton = false
                }
            }
        })
        
    }
    
    func setEditMode(editMode: Bool) {
        stepsTableView.setEditing(editMode, animated: true)
        
        if editMode {
            showAddStepButton()
            populateStepsCopy()
            
            stepsTableView.reloadData()
        } else {
            hideAddStepButton()
            
            stepsTableView.reloadData()
        }
    }
    
    private func hideAddStepButton() {
        addStepButton.isHidden = true
        
        stepsTableViewBottomToButtonConstraint.isActive = false
        stepsTableViewBottomToScreenBottomConstraint?.isActive = true
    }
    
    private func showAddStepButton() {
        addStepButton.isHidden = false
        
        stepsTableViewBottomToScreenBottomConstraint?.isActive = false
        stepsTableViewBottomToButtonConstraint = stepsTableView.bottomAnchor.constraint(equalTo: addStepButton.topAnchor)
        stepsTableViewBottomToButtonConstraint.isActive = true
    }
    
    private func populateStepsCopy() {
        stepsCopy.removeAll()
        
        for step in steps {
            let stepCopy = step
            
            stepsCopy.append(stepCopy)
        }
    }
    
    private func validateChangedSteps(validationFailed completion: @escaping (Bool) -> Void) {
        removeEmptySteps()
        
        for step in stepsCopy where step.isEmpty {
            completion(true)
            
            return
        }
        
        completion(false)
    }
    
    private func removeEmptySteps() {
        if createRecipeMode {
            createRecipeSteps.forEach({
                if $0.isEmpty {
                    let stepIndex = createRecipeSteps.lastIndex(of: $0)
                    
                    if let index = stepIndex {
                        createRecipeSteps.remove(at: index)
                    }
                }
            })
        } else {
            stepsCopy.forEach({
                if $0.isEmpty {
                    let stepIndex = stepsCopy.lastIndex(of: $0)
                    
                    if let index = stepIndex {
                        stepsCopy.remove(at: index)
                    }
                }
            })
        }
    }
    
    private func areStepsChanged() -> Bool {
        if steps != stepsCopy {
            return true
        } else {
            for index in steps.indices where steps[index] != stepsCopy[index] {
                return true
            }
        }
        
        return false
    }
    
    private func refreshSteps() {
        if let recipeSteps = recipe?.steps, recipeSteps.count > 0 {
            steps = recipeSteps
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            self.addStepButtonBottomConstraint.constant = keyboardRectangle.height + 4
        }
    }
    
    @objc func keyboardWillHide() {
        self.addStepButtonBottomConstraint.constant = 10
    }
    
}

extension StepsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if createRecipeMode {
            return createRecipeSteps.count
        } else {
            return tableView.isEditing ? stepsCopy.count : steps.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "changeStepCell") as? ChangeRecipeStepCell else {
                fatalError("cell should be ChangeRecipeStepCell type")
            }
            
            cell.index = indexPath.row
            
            cell.delegate = self
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)."
            cell.stepDetailsTextField.text = createRecipeMode ? createRecipeSteps[indexPath.row] : stepsCopy[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as? RecipeStepCell else {
                fatalError("cell should be RecipeStepCell type")
            }
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)."
            cell.stepDetailLabel.text = steps[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if createRecipeMode {
            return 100.0
        } else {
            if let font = UIFont(name: FontName.regular.rawValue, size: 16.0) {
                return steps[indexPath.row].height(withConstrainedWidth: self.stepsTableView.frame.width - 152,
                                                   font: font) + 32
            }
            
            return 60.0
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if createRecipeMode {
            let movedStep = createRecipeSteps[sourceIndexPath.row]
            
            createRecipeSteps.remove(at: sourceIndexPath.row)
            createRecipeSteps.insert(movedStep, at: destinationIndexPath.row)
        } else {
            let movedStep = stepsCopy[sourceIndexPath.row]
            
            stepsCopy.remove(at: sourceIndexPath.row)
            stepsCopy.insert(movedStep, at: destinationIndexPath.row)
        }
        
        stepsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if createRecipeMode {
                createRecipeSteps.remove(at: indexPath.row)
            } else {
                stepsCopy.remove(at: indexPath.row)
            }
            
            if (createRecipeMode && self.createRecipeSteps.count == 0) ||
                (self.stepsTableView.isEditing && self.stepsCopy.count == 0) ||
                (self.steps.count == 0) {
                self.noStepsAddedLabel.isHidden = true
            }
            
            stepsTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing == false {
            if let selectedStepCell = tableView.cellForRow(at: indexPath) as? RecipeStepCell {
                selectedStepCell.changeCheckedState(to: !selectedStepCell.checkbox.isChecked)
            }
        }
    }
    
    // Change default icon (hamburger) for moving cells in UITableView
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let imageView = cell.subviews.first(where: { $0.description.contains("Reorder") })?.subviews[0] as? UIImageView
        
        let image = UIImage(systemName: "line.horizontal.3")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal)
        imageView?.image = image
    }
    
}

extension StepsViewController: ChangeRecipeStepCellDelegate {
    
    func stepDetailsFieldSelected(withText text: String?, atIndex index: Int) {
        let stepExtendedTextView = StepExtendedTextView()
        
        UIView.animate(withDuration: 0.1) {
            self.view.addSubview(stepExtendedTextView)
        } completion: { finished in
            stepExtendedTextView.stepDetailsTextView.becomeFirstResponder()
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        
        stepExtendedTextView.delegate = self
        
        stepExtendedTextView.translatesAutoresizingMaskIntoConstraints = false
        stepExtendedTextView.stepDetailsTextView.text = text
        stepExtendedTextView.index = index
        
        NSLayoutConstraint.activate([stepExtendedTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     stepExtendedTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     stepExtendedTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     stepExtendedTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
    }
    
    func stepChanged(withValue string: String?, atIndex index: Int) {
        if createRecipeMode {
            createRecipeSteps[index] = string ?? ""
        } else {
            stepsCopy[index] = string ?? ""
        }
    }
    
}

extension StepsViewController: StepExtendedTextViewDelegate {
    
    func stepDetailsSaved(withText text: String?, atIndex index: Int) {
        if createRecipeMode {
            createRecipeSteps[index] = text ?? ""
        } else {
            stepsCopy[index] = text ?? ""
        }
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        stepsTableView.reloadData()
    }
    
    func stepDetailsCanceled() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
    
}
