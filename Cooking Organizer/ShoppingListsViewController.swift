//
//  ShoppingListsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class ShoppingListsViewController: UIViewController {
    @IBOutlet weak var listsTableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var shoppingLists: [ShoppingList]? {
        return UsersManager.shared.currentLoggedInUser?.shoppingListsArray ?? nil
    }
    
    var copyOfShoppingLists: [ShoppingList]?
    
    var deletedLists = [String]()
    
    var selectedShoppingList: ShoppingList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listsTableView.delegate = self
        listsTableView.dataSource = self
        listsTableView.allowsSelectionDuringEditing = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserDataManager.shared.delegate = self
        
        listsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedShoppingListSegue", let destVC = segue.destination as? ShoppingListViewController {
            destVC.selectedShoppingList = selectedShoppingList
        }
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
        if deletedLists.isEmpty {
            setupScreen(forEditMode: false)
        } else {
            let dispatchGroup = DispatchGroup()
            
            for listName in deletedLists {
                dispatchGroup.enter()
                
                UserDataManager.shared.removeShoppingList(withName: listName) {
                    dispatchGroup.leave()
                } failure: {
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.setupScreen(forEditMode: false)
            }
        }
    }
    
    private func setupScreen(forEditMode editMode: Bool) {
        listsTableView.setEditing(editMode, animated: true)
        
        navigationItem.hidesBackButton = editMode
        navigationItem.leftBarButtonItem = editMode ? UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelPressed)) : nil
        navigationItem.rightBarButtonItem = editMode ? UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(savePressed)) : UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editPressed))
        
        addButton.isHidden = editMode
        
        copyOfShoppingLists = editMode ? shoppingLists : nil
        
        if !editMode {
            deletedLists.removeAll()
        }
        
        listsTableView.reloadData()
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let createListView = CreateShoppingListView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        createListView.translatesAutoresizingMaskIntoConstraints = false
        
        createListView.invalidName = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Invalid List Name",
                                                              message: "Please choose another list name!")
        }
        
        createListView.creationFailed = {
            AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                              title: "Creation Failed",
                                                              message: "Something went wrong creating the shopping list")
        }
        
        view.addSubview(createListView)
        
        NSLayoutConstraint.activate([createListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                     createListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                     createListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                     createListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
    }
}

extension ShoppingListsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView.isEditing ? copyOfShoppingLists?.count ?? 0 : shoppingLists?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = tableView.isEditing ? copyOfShoppingLists?[indexPath.row].name : shoppingLists?[indexPath.row].name
        
        let itemsCount = tableView.isEditing ? copyOfShoppingLists?[indexPath.row].items?.count ?? 0 : shoppingLists?[indexPath.row].items?.count ?? 0
        
        cell.detailTextLabel?.text = "\(itemsCount) items"
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let createListView = CreateShoppingListView(inChangeMode: true, withName: copyOfShoppingLists?[indexPath.row].name, frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            
            createListView.translatesAutoresizingMaskIntoConstraints = false
            
            createListView.invalidName = {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Invalid List Name",
                                                                  message: "Please choose another list name!")
            }
            
            createListView.creationFailed = {
                AlertManager.showAlertWithTitleMessageAndOKButton(onPresenter: self,
                                                                  title: "Creation Failed",
                                                                  message: "Something went wrong creating the shopping list")
            }
            
            view.addSubview(createListView)
            
            NSLayoutConstraint.activate([createListView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
                                         createListView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                                         createListView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                                         createListView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)])
        } else {
            selectedShoppingList = shoppingLists?[indexPath.row]
        
            performSegue(withIdentifier: "selectedShoppingListSegue", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let deletedListName = shoppingLists?[indexPath.row].name {
                deletedLists.append(deletedListName)
                
                copyOfShoppingLists?.remove(at: indexPath.row)
                
                listsTableView.reloadData()
            }
        }
    }
}

extension ShoppingListsViewController: UserDataManagerDelegate {
    func shoppingListsChanged() {
        if listsTableView.isEditing {
            copyOfShoppingLists = shoppingLists
        }
        
        listsTableView.reloadData()
    }
}
