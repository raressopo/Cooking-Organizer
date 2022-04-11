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
            if section == .photo {
                return 1
            } else if section == .portions {
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
                    cell.textView.text = "• No cooking time added"
                case .difficulty:
                    cell.textView.text = "• No difficulty added"
                case .lastCook:
                    cell.textView.text = "• Never cooked"
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
            let headerView = NewRecipeSectionHeaderView(withFrame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 60))
            
            headerView.configure(withNewRecipeSection: section)
            
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
}
