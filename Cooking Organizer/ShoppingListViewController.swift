//
//  ShoppingListViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var selectedShoppingList: ShoppingList?
    
    var items: [ShoppingListItem]? {
        if let selectedList = selectedShoppingList,
           let userList = UsersManager.shared.currentLoggedInUser?.shoppingListsArray,
           let existingList = userList.first(where: {$0.name == selectedList.name})
        {
            return existingList.itemsArray?.sorted(by: {!$0.bought && $1.bought}) ?? nil
        } else {
            return nil
        }
    }
    
    var copyOfItems: [ShoppingListItem]?
    
    var deletedItems = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemsTableView.delegate = self
        itemsTableView.dataSource = self
        
        itemsTableView.allowsSelectionDuringEditing = true
        
        itemsTableView.register(UINib(nibName: "ShoppingListItemTableViewCell", bundle: nil), forCellReuseIdentifier: "shoppingListItemCell")
        
        UserDataManager.shared.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        navigationItem.title = selectedShoppingList?.name ?? "Shopping List"
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let addListItemView = AddShoppingListItemView(shoppingList: selectedShoppingList,frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        addListItemView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addListItemView)
        
        NSLayoutConstraint.activate([addListItemView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                     addListItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                     addListItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                     addListItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
    }
    
    @objc
    private func editPressed() {
        setupScreen(forEditMode: true)
    }
    
    @objc
    private func cancelPressed() {
        setupScreen(forEditMode: false)
    }
    
    @objc
    private func savePressed() {
        if let listName = selectedShoppingList?.name, !deletedItems.isEmpty {
            let dispatchGroup = DispatchGroup()
            
            for itemName in deletedItems {
                dispatchGroup.enter()
                
                UserDataManager.shared.removeShoppingListItem(fromList: listName, withItemName: itemName) {
                    dispatchGroup.leave()
                } failure: {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.setupScreen(forEditMode: false)
            }
        } else {
            setupScreen(forEditMode: false)
        }
    }
    
    private func setupScreen(forEditMode editMode: Bool) {
        itemsTableView.setEditing(editMode, animated: true)
        
        navigationItem.hidesBackButton = editMode
        navigationItem.leftBarButtonItem = editMode ? UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed)) : nil
        navigationItem.rightBarButtonItem = editMode ? UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed)) : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        
        addButton.isHidden = editMode
        
        copyOfItems = editMode ? items : nil
        
        if !editMode {
            deletedItems.removeAll()
        }
        
        itemsTableView.reloadData()
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? copyOfItems?.count ?? 0 : items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shoppingListItemCell") as? ShoppingListItemTableViewCell else {
            fatalError("Cell type is not ShoppingListItemTableViewCell")
        }
        
        let item = tableView.isEditing ? copyOfItems?[indexPath.row] : items?[indexPath.row]
        
        cell.itemNameLabel.text = item?.name
        cell.itemQuantityAndUnitLabel.text = "\(item?.quantity ?? 0) \(item?.unit ?? "")"
        cell.checkbox.isHidden = tableView.isEditing
        cell.checkbox.isChecked = item?.bought ?? false
        cell.boughtView.isHidden = !cell.checkbox.isChecked
        
        cell.checkbox.valueChanged = { (isChecked) in
            if let listName = self.selectedShoppingList?.name, let itemName = item?.name, let bought = item?.bought {
                UserDataManager.shared.markShoppingListAsBought(fromList: listName, forItem: itemName, bought: !bought, success: {}, failure: {})
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deletedItemName = items?[indexPath.row].name {
                deletedItems.append(deletedItemName)
                
                copyOfItems?.remove(at: indexPath.row)
                
                itemsTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let addListItemView = AddShoppingListItemView(changeMode: true,
                                                          shoppingListItem: copyOfItems?[indexPath.row],
                                                          shoppingList: selectedShoppingList,
                                                          frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            addListItemView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(addListItemView)
            
            NSLayoutConstraint.activate([addListItemView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                         addListItemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                         addListItemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                         addListItemView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
        } else {
            if let listName = selectedShoppingList?.name, let itemName = items?[indexPath.row].name, let bought = items?[indexPath.row].bought {
                UserDataManager.shared.markShoppingListAsBought(fromList: listName, forItem: itemName, bought: !bought) {
                    
                } failure: {
                    
                }
            }
        }
    }
}

extension ShoppingListViewController: UserDataManagerDelegate {
    func shoppingListsChanged() {
        if itemsTableView.isEditing {
            copyOfItems = items
        }
        
        itemsTableView.reloadData()
    }
}
