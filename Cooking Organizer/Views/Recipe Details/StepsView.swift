//
//  StepsView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 15/09/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol StepsViewDelegate: class {
    func stepDeleted()
}

class StepsView: UIView {
    var tableView = UITableView()
    var addStepButton = UIButton()
    
    var steps = [String]()
    var stepsCopy = [String]()
    
    weak var delegate: StepsViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        populateStepsCopy()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func setEditMode(editMode: Bool) {
        tableView.setEditing(editMode, animated: true)
        
        if editMode {
            setupAddStepButton()
            populateStepsCopy()
            
            tableView.reloadData()
        } else {
            removeAddStepButton()
            
            tableView.reloadData()
        }
    }
    
    func validateChangedSteps(validationFailed completion: @escaping (Bool) -> Void) {
        for step in stepsCopy {
            if step.isEmpty {
                completion(true)
                
                return
            }
        }
        
        completion(false)
    }
    
    func areStepsChanged() -> Bool {
        if steps != stepsCopy {
            return true
        } else {
            for index in steps.indices {
                if steps[index] != stepsCopy[index] {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private Helpers
    
    private func setupTableView() {
        tableView = UITableView()
        
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        constraintsSetup(inEditMode: false)
        
        tableView.register(UINib(nibName: "RecipeStepCell", bundle: nil), forCellReuseIdentifier: "stepCell")
        tableView.register(UINib(nibName: "ChangeRecipeStepCell", bundle: nil), forCellReuseIdentifier: "changeStepCell")
    }
    
    private func constraintsSetup(inEditMode editMode: Bool) {
        removeConstraints(constraints)
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        if editMode {
            tableView.bottomAnchor.constraint(equalTo: addStepButton.topAnchor).isActive = true
            
            addStepButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            addStepButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
            addStepButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
            addStepButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        } else {
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }
    }
    
    private func setupAddStepButton() {
        addStepButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        addStepButton.setTitle("+ Add Step", for: .normal)
        addStepButton.setTitleColor(.systemBlue, for: .normal)
        addStepButton.addTarget(self, action: #selector(addStepPressed), for: .touchUpInside)
        
        addSubview(addStepButton)
        
        addStepButton.translatesAutoresizingMaskIntoConstraints = false
     
        constraintsSetup(inEditMode: true)
    }
    
    private func removeAddStepButton() {
        addStepButton.removeFromSuperview()
        
        constraintsSetup(inEditMode: false)
    }
    
    private func populateStepsCopy() {
        stepsCopy.removeAll()
        
        for step in steps {
            let stepCopy = step
            
            stepsCopy.append(stepCopy)
        }
    }
    
    // MARK: - Selectors
    
    @objc func addStepPressed() {
        let step = String()
        
        stepsCopy.append(step)
        
        tableView.reloadData()
    }
}

// MARK: - TableView Delegate and DataSource

extension StepsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? stepsCopy.count : steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeStepCell") as! ChangeRecipeStepCell
            
            cell.index = indexPath.row
            
            cell.delegate = self
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailsTextField.text = stepsCopy[indexPath.row]
            
            cell.selectionStyle = .none
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "stepCell") as! RecipeStepCell
            
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
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            stepsCopy.remove(at: indexPath.row)
            
            delegate?.stepDeleted()
            
            tableView.reloadData()
        }
    }
}

// MARK: - Change Recipe Step Cell Delegate

extension StepsView: ChangeRecipeStepCellDelegate {
    func stepChanged(withValue string: String?, atIndex index: Int) {
        stepsCopy[index] = string ?? ""
    }
}
