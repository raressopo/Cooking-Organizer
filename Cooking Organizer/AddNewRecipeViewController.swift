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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewRecipeSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == section }) {
            if section == .portions {
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
                
                return cell
            case .photo:
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageViewCell") as? AddChangeRecipeImageCell else {
                    fatalError()
                }
                
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
                    cell.textView.text = "• No categories selected"
                default:
                    break
                }
                
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
            let headerView = NewRecipeSectionHeaderView(withFrame: CGRect(x: 0,
                                                                          y: 0,
                                                                          width: self.tableView.frame.width,
                                                                          height: 60))
            
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
            default:
                break
            }
            
            headerView.configure(withNewRecipeSection: section, andDelegate: self, withAddButton: shouldHaveAddButton)
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let section = NewRecipeSection.allCases.first(where: { $0.sectionIndex() == indexPath.section }) {
            if section == .photo {
                return 215
            } else if section == .name {
                return 75
            }
        }
        
        return 50
    }
    
    @objc func changeAddCookingTimePressed() {
        let cookingTimePickerView = CookingTimePickerView()
        
        cookingTimePickerView.delegate = self
        
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
        
        self.tableView.reloadSections([NewRecipeSection.cookingTime.sectionIndex()], with: .automatic)
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
