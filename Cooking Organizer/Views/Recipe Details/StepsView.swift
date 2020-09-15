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

extension StepsViewDelegate {
    func stepDeleted() {}
}

class StepsView: UIView, UITableViewDelegate, UITableViewDataSource, ChangeRecipeStepCellDelegate {
    var tableView = UITableView()
    var addStepButton = UIButton()
    
    var steps = [String]()
    var changingSteps = [String]()
    
    weak var delegate: StepsViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupAddStepButton() {
        addStepButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60.0))
        addStepButton.setTitle("+ Add Step", for: .normal)
        addStepButton.setTitleColor(.systemBlue, for: .normal)
        addStepButton.addTarget(self, action: #selector(addStepPressed), for: .touchUpInside)
        
        addSubview(addStepButton)
        
        addStepButton.translatesAutoresizingMaskIntoConstraints = false
        
        removeConstraints(constraints)
        
        addStepButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        addStepButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8.0).isActive = true
        addStepButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0).isActive = true
        addStepButton.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: addStepButton.topAnchor).isActive = true
        
        changingSteps.removeAll()
        
        for step in steps {
            let stepCopy = step
            
            changingSteps.append(stepCopy)
        }
    }
    
    @objc func addStepPressed() {
        let step = String()
        
        changingSteps.append(step)
        
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView = UITableView()
        
        addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        tableView.register(UINib(nibName: "RecipeStepCell", bundle: nil), forCellReuseIdentifier: "stepCell")
        tableView.register(UINib(nibName: "ChangeRecipeStepCell", bundle: nil), forCellReuseIdentifier: "changeStepCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? changingSteps.count : steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.isEditing {
            let cell = tableView.dequeueReusableCell(withIdentifier: "changeStepCell") as! ChangeRecipeStepCell
            
            cell.index = indexPath.row
            
            cell.delegate = self
            
            cell.stepNrLabel.text = "\(indexPath.row + 1)"
            cell.stepDetailsTextField.text = changingSteps[indexPath.row]
            
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
        let movedStep = changingSteps[sourceIndexPath.row]
        changingSteps.remove(at: sourceIndexPath.row)
        changingSteps.insert(movedStep, at: destinationIndexPath.row)
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            changingSteps.remove(at: indexPath.row)
            
            delegate?.stepDeleted()
            
            tableView.reloadData()
        }
    }
    
    func removeAddStepButton() {
        addStepButton.removeFromSuperview()
        
        removeConstraints(constraints)
        
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    func validateChangedSteps(validationFailed completion: @escaping (Bool) -> Void) {
        for step in changingSteps {
            if step.isEmpty {
                completion(true)
                
                return
            }
        }
        
        completion(false)
    }
    
    func areStepsChanged() -> Bool {
        if steps != changingSteps {
            return true
        } else {
            for index in steps.indices {
                if steps[index] != changingSteps[index] {
                    return true
                }
            }
        }
        
        return false
    }
    
    func stepChanged(withValue string: String?, atIndex index: Int) {
        changingSteps[index] = string ?? ""
    }
}
