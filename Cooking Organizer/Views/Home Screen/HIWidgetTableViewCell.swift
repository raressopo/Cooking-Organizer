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

class HIWidgetTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var HIWidgetTableView: UITableView!
    
    weak var delegate: HIWidgetTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        HIWidgetTableView.delegate = self
        HIWidgetTableView.dataSource = self
        
        HIWidgetTableView.register(UINib(nibName: "HomeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "homeIngredientCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let homeIngredientsCount = UsersManager.shared.currentLoggedInUser?.data.homeIngredients else {
            return 0
        }
        
        return homeIngredientsCount.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeIngredientCell") as! HomeIngredientTableViewCell
        
//        if let homeIngredient = UsersManager.shared.currentLoggedInUser?.data.homeIngredients?[indexPath.row] {
//            let ingredient = homeIngredient.values
//            
//            cell.selectionStyle = .none
//            
//            cell.name.text = homeIngredient.name
//            cell.expirationDate.text = homeIngredient.expirationDate
//            cell.quantityAndUnit.text = "\(homeIngredient.quantity ?? 0.0) \(homeIngredient.unit ?? "")"
//        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // if let homeIngredient = UsersManager.shared.currentLoggedInUser?.data.homeIngredients?[indexPath.row] {
            //delegate?.homeIngredientPressed(withHomeIngredient: homeIngredient)
        //}
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
}
