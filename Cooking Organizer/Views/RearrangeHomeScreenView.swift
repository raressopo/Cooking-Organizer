//
//  RearrangeHomeScreenView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 18/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

enum HomeScreenCells: CaseIterable {
    case HomeIngredients
    case Cookbook
    case CookingCalendar
    
    var cellName: String {
        switch self {
        case .HomeIngredients:
            return "Home Ingredients"
        case .Cookbook:
            return "Cookbook"
        case .CookingCalendar:
            return "Cooking Calendar"
        }
    }
}

class RearrangeHomeScreenView: UIView {
    @IBOutlet var contentView: UIView!
    
    @IBOutlet weak var homeScreenCellsTableView: UITableView!
    
    var homeScreenCellsOrder = [HomeScreenCells.HomeIngredients,
                                HomeScreenCells.Cookbook,
                                HomeScreenCells.CookingCalendar]
    
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
            results = savedOrder.map( {
                switch $0 {
                case HomeScreenCells.HomeIngredients.cellName:
                    return .HomeIngredients
                case HomeScreenCells.Cookbook.cellName:
                    return .Cookbook
                case HomeScreenCells.CookingCalendar.cellName:
                    return .CookingCalendar
                default:
                    return .HomeIngredients
                }
            })
        }
        
        return results
    }
    
    @IBAction func dissmisBackgroundPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        removeFromSuperview()
    }
    
    @IBAction func savePressed(_ sender: Any) {
        UserDefaults.standard.setValue(homeScreenCellsOrder.map( {$0.cellName} ), forKey: "savedHomeScreenCellsOrder")
        
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
