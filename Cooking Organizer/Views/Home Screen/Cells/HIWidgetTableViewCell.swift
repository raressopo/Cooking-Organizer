//
//  HIWidgetTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol HIWidgetTableViewCellDelegate: class {
    func homeIngredientPressed(withHomeIngredient hi: HomeIngredient)
}

class HIWidgetTableViewCell: UITableViewCell {
    @IBOutlet weak var HIWidgetTableView: UITableView!
    
    weak var delegate: HIWidgetTableViewCellDelegate?
    
    var homeIngredients: [HomeIngredient]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        HIWidgetTableView.delegate = self
        HIWidgetTableView.dataSource = self
        
        homeIngredients = UsersManager.shared.currentLoggedInUser?.homeIngredients
        
        HIWidgetTableView.register(UINib(nibName: "HomeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "homeIngredientCell")
    }
}

// MARK: - TableView Delegate and DataSource

extension HIWidgetTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let homeIngredientsCount = homeIngredients?.count else {
            return 0
        }
        
        return homeIngredientsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeIngredientCell") as? HomeIngredientTableViewCell else {
            fatalError("Unexpected Cell Indentifier")
            
        }
        
        cell.selectionStyle = .none
        
        if let homeIngredient = homeIngredients?[indexPath.row] {
            cell.name.text = homeIngredient.name
            cell.expirationDate.text = homeIngredient.expirationDate
            cell.quantityAndUnit.text = "\(homeIngredient.quantityAsString) \(homeIngredient.unit ?? "")"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let homeIngredient = homeIngredients?[indexPath.row] {
            delegate?.homeIngredientPressed(withHomeIngredient: homeIngredient)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}
