//
//  RearrangeHomeScreenView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum HomeScreenCells: CaseIterable {
    case homeIngredients
    case cookbook
    case cookingCalendar
    case shoppingList
    
    var cellName: String {
        switch self {
        case .homeIngredients:
            return "Home Ingredients"
        case .cookbook:
            return "Cookbook"
        case .cookingCalendar:
            return "Cooking Calendar"
        case .shoppingList:
            return "Shopping List"
        }
    }
}

class RearrangeHomeScreenView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var homeScreenCellsTableView: UITableView!
    
    var homeScreenCellsOrder = [HomeScreenCells.homeIngredients,
                                HomeScreenCells.cookbook,
                                HomeScreenCells.cookingCalendar,
                                HomeScreenCells.shoppingList]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RearrangeHomeScreenView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        homeScreenCellsOrder = RearrangeHomeScreenView.getSavedHomeScreenOrder()
        
        homeScreenCellsTableView.delegate = self
        homeScreenCellsTableView.dataSource = self
        
        homeScreenCellsTableView.setEditing(true, animated: true)
    }
    
    class func getSavedHomeScreenOrder() -> [HomeScreenCells] {
        var results = [HomeScreenCells]()
        
        if let savedOrder = UserDefaults.standard.object(forKey: "savedHomeScreenCellsOrder") as? [String] {
            results = savedOrder.map {
                switch $0 {
                case HomeScreenCells.homeIngredients.cellName:
                    return .homeIngredients
                case HomeScreenCells.cookbook.cellName:
                    return .cookbook
                case HomeScreenCells.cookingCalendar.cellName:
                    return .cookingCalendar
                case HomeScreenCells.shoppingList.cellName:
                    return .shoppingList
                default:
                    return .homeIngredients
                }
            }
            
            return results
        } else {
            return [HomeScreenCells.homeIngredients,
                    HomeScreenCells.cookbook,
                    HomeScreenCells.cookingCalendar,
                    HomeScreenCells.shoppingList]
        }
    }
    
    @IBAction func dissmisBackgroundPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        UserDefaults.standard.setValue(homeScreenCellsOrder.map { $0.cellName }, forKey: "savedHomeScreenCellsOrder")
        
        removeFromSuperview()
    }
}

extension RearrangeHomeScreenView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeScreenCellsOrder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = homeScreenCellsOrder[indexPath.row].cellName
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedCell = homeScreenCellsOrder[sourceIndexPath.row]
        homeScreenCellsOrder.remove(at: sourceIndexPath.row)
        homeScreenCellsOrder.insert(movedCell, at: destinationIndexPath.row)
        
        homeScreenCellsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}
