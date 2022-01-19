//
//  StepsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/01/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import UIKit

class StepsViewController: UIViewController {
    @IBOutlet weak var stepsTableView: UITableView!
    @IBOutlet weak var addStepButton: UIButton!
    
    @IBOutlet weak var stepsTableViewBottomToButtonConstraint: NSLayoutConstraint!
    var stepsTableViewBottomToScreenBottomConstraint: NSLayoutConstraint?
    
    var steps = [String]()
    var stepsCopy = [String]()
    
    var recipe: Recipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepsTableView.delegate = self
        stepsTableView.dataSource = self
        
        stepsTableViewBottomToButtonConstraint.isActive = false
        addStepButton.isHidden = true
        
        stepsTableViewBottomToScreenBottomConstraint = stepsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        stepsTableViewBottomToScreenBottomConstraint?.isActive = true
        
        stepsTableView.register(UINib(nibName: "RecipeStepCell", bundle: nil), forCellReuseIdentifier: "stepCell")
        stepsTableView.register(UINib(nibName: "ChangeRecipeStepCell", bundle: nil), forCellReuseIdentifier: "changeStepCell")
        
        let editNavBarButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        
        self.navigationItem.rightBarButtonItem = editNavBarButton
    }
    
    @IBAction func addStepPressed(_ sender: Any) {
        let step = String()
        
        stepsCopy.append(step)
        
        stepsTableView.reloadData()
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
                }
                
                if let userId = UsersManager.shared.currentLoggedInUser?.loginData.id,
                    let recipeId = self.recipe?.id,
                    !changedSteps.isEmpty {
                    
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
            shouldHideAddStepButton(hide: false)
            populateStepsCopy()
            
            stepsTableView.reloadData()
        } else {
            shouldHideAddStepButton(hide: true)
            
            stepsTableView.reloadData()
        }
    }
    
    private func shouldHideAddStepButton(hide: Bool) {
        addStepButton.isHidden = hide
        
        stepsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = hide
        stepsTableViewBottomToScreenBottomConstraint?.isActive = !hide
    }
    
    private func setupAddStepButton() {
        stepsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = false
        
        stepsTableViewBottomToButtonConstraint.isActive = true
        addStepButton.isHidden = false
    }
    
    private func removeAddStepButton() {
        addStepButton.isHidden = true
        
        stepsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func populateStepsCopy() {
        stepsCopy.removeAll()
        
        for step in steps {
            let stepCopy = step
            
            stepsCopy.append(stepCopy)
        }
    }
    
    private func validateChangedSteps(validationFailed completion: @escaping (Bool) -> Void) {
        for step in stepsCopy where step.isEmpty {
            completion(true)
            
            return
        }
        
        completion(false)
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
        return tableView.isEditing ? stepsCopy.count : steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "changeStepCell") as? ChangeRecipeStepCell else {
                fatalError("cell should be ChangeRecipeStepCell type")
            }
            
            cell.index = indexPath.row
            
            cell.delegate = self
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailsTextField.text = stepsCopy[indexPath.row]
            
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
        let movedStep = stepsCopy[sourceIndexPath.row]
        stepsCopy.remove(at: sourceIndexPath.row)
        stepsCopy.insert(movedStep, at: destinationIndexPath.row)
        
        stepsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stepsCopy.remove(at: indexPath.row)
            
            stepsTableView.reloadData()
        }
    }
    
}

extension StepsViewController: ChangeRecipeStepCellDelegate {
    
    func stepDetailsFieldSelected(withText text: String?, atIndex index: Int) {
        let stepExtendedTextView = StepExtendedTextView()
        
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
    
    func stepChanged(withValue string: String?, atIndex index: Int) {
        stepsCopy[index] = string ?? ""
    }
    
}

extension StepsViewController: StepExtendedTextViewDelegate {
    
    func stepDetailsSaved(withText text: String?, atIndex index: Int) {
        stepsCopy[index] = text ?? ""
        
        stepsTableView.reloadData()
    }
    
}
