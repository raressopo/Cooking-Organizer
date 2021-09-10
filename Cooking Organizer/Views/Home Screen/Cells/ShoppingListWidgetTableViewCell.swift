//
//  ShoppingListWidgetTableViewCell.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 29/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol ShoppingListWidgetTableViewCellDelegate: AnyObject {
    func didSelectShoppingList(list: ShoppingList)
}

class ShoppingListWidgetTableViewCell: UITableViewCell {
    @IBOutlet weak var listOrItemsTableView: UITableView!
    
    weak var delegate: ShoppingListWidgetTableViewCellDelegate?
    
    var shoppingLists: [ShoppingList]? {
        return UsersManager.shared.currentLoggedInUser?.shoppingListsArray ?? nil
    }
    
    var items: [ShoppingListItem]? {
        if shoppingLists?.count == 1, let shoppingList = shoppingLists?.first {
            if let userList = UsersManager.shared.currentLoggedInUser?.shoppingListsArray,
               let existingList = userList.first(where: {$0.name == shoppingList.name})
            {
                return existingList.itemsArray?.sorted(by: {!$0.bought && $1.bought}) ?? nil
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        listOrItemsTableView.delegate = self
        listOrItemsTableView.dataSource = self
        
        UserDataManager.shared.shoppingListsDelegate = self
        
        listOrItemsTableView.register(UINib(nibName: "ShoppingListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "shoppingListItemCell")
    }
}

extension ShoppingListWidgetTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let listsCount = shoppingLists?.count {
            if listsCount == 1 {
                return items?.count ?? 0
            } else {
                return listsCount
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItems = items, let list = shoppingLists?.first {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListItemCell") as? ShoppingListItemTableViewCell else {
                fatalError("Cell type is not ShoppingListItemTableViewCell")
            }
            
            let item = listItems[indexPath.row]
            
            cell.itemNameLabel.text = item.name
            cell.itemQuantityAndUnitLabel.text = "\(item.quantity ?? 0) \(item.unit ?? "")"
            cell.checkbox.isHidden = tableView.isEditing
            cell.checkbox.isChecked = item.bought
            cell.boughtView.isHidden = !cell.checkbox.isChecked
            
            cell.checkbox.valueChanged = { (isChecked) in
                if let listName = list.name, let itemName = item.name {
                    UserDataManager.shared.markShoppingListAsBought(fromList: listName,
                                                                    forItem: itemName,
                                                                    bought: !item.bought,
                                                                    success: {},
                                                                    failure: {})
                }
            }
            
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            
            cell.textLabel?.text = shoppingLists?[indexPath.row].name
            cell.detailTextLabel?.text = "\(shoppingLists?[indexPath.row].items?.count ?? 0) items"
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let listItems = items, let list = shoppingLists?.first {
            if let listName = list.name, let itemName = listItems[indexPath.row].name {
                UserDataManager.shared.markShoppingListAsBought(fromList: listName,
                                                                forItem: itemName,
                                                                bought: !listItems[indexPath.row].bought,
                                                                success: {},
                                                                failure: {})
            }
        } else {
            if let selectedShoppingList = shoppingLists?[indexPath.row] {
                delegate?.didSelectShoppingList(list: selectedShoppingList)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

extension ShoppingListWidgetTableViewCell: UserDataManagerDelegate {
    func shoppingListsChanged() {
        listOrItemsTableView.reloadData()
    }
}
