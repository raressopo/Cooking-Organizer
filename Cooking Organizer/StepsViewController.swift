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
    @IBOutlet weak var addStepButton: UIButton!
    
    @IBOutlet weak var stepsTableViewBottomToButtonConstraint: NSLayoutConstraint!
    
    var stepsTableViewBottomToScreenBottomConstraint: NSLayoutConstraint?
    
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
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        
        self.navigationItem.hidesBackButton = false
    }
    
    @IBAction func addStepPressed(_ sender: Any) {
        let step = String()
        
        if createRecipeMode {
            createRecipeSteps.append(step)
        } else {
            stepsCopy.append(step)
        }
        
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
                    
                    FirebaseAPIManager.sharedInstance.updateRecipe(froUserId: userId,
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
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailsTextField.text = createRecipeMode ? createRecipeSteps[indexPath.row] : stepsCopy[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as? RecipeStepCell else {
                fatalError("cell should be RecipeStepCell type")
            }
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailsTextView.text = steps[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
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
            
            stepsTableView.reloadData()
        }
    }
    
}

extension StepsViewController: ChangeRecipeStepCellDelegate {
    
    func stepDetailsFieldSelected(withText text: String?, atIndex index: Int) {
        let stepExtendedTextView = StepExtendedTextView()
        
        view.addSubview(stepExtendedTextView)
        
        stepExtendedTextView.delegate = self
        
        //stepExtendedTextView.becomeFirstResponder()
        stepExtendedTextView.translatesAutoresizingMaskIntoConstraints = false
        stepExtendedTextView.stepDetailsTextView.text = text
        stepExtendedTextView.index = index
        
        NSLayoutConstraint.activate([stepExtendedTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0.0),
                                     stepExtendedTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0),
                                     stepExtendedTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0.0),
                                     stepExtendedTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0.0)])
        
        stepExtendedTextView.stepDetailsTextView.becomeFirstResponder()
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
        
        stepsTableView.reloadData()
    }
    
}
