//
//  HomeIngredientsViewController.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 26/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeIngredientsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserDataManagerDelegate {
    @IBOutlet weak var addHomeIngrButton: UIButton!
    
    @IBOutlet weak var homeIngredientsTableView: UITableView!
    
    var homeIngredients = [HomeIngredient]()
    
    var widgetHomeIngredient: HomeIngredient?
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Home Ingredients"
        
        homeIngredientsTableView.delegate = self
        homeIngredientsTableView.dataSource = self
        
        UserDataManager.shared.delegate = self
        
        homeIngredientsTableView.register(UINib(nibName: "HomeIngredientTableViewCell", bundle: nil), forCellReuseIdentifier: "homeIngredientCell")
        
        if let currentUser = UsersManager.shared.currentLoggedInUser {
            homeIngredients = currentUser.homeIngredients
            
            homeIngredientsTableView.reloadData()
        }
        
        if let ingredient = widgetHomeIngredient {
            let ingredientDetailsView = HomeIngredientDetailsView()
            
            ingredientDetailsView.populateFields(withIngredient: ingredient)
            
            view.addSubview(ingredientDetailsView)
            
            ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                         ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                         ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                         ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
            
            ingredientDetailsView.createButton.setTitle("Change", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        widgetHomeIngredient = nil
    }
    
    // MARK: - IBActions
    
    @IBAction func addPressed(_ sender: Any) {
        let ingredientDetailsView = HomeIngredientDetailsView()
        
        view.addSubview(ingredientDetailsView)
        
        ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
    }
    
    // MARK: - TableView delegates and datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeIngredients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeIngredientCell", for: indexPath) as! HomeIngredientTableViewCell
        
        let homeIngredient = homeIngredients[indexPath.row]
        
        cell.name.text = homeIngredient.name
        cell.expirationDate.text = homeIngredient.expirationDate
        cell.quantityAndUnit.text = "\(homeIngredient.quantity ?? 0.0) \(homeIngredient.unit ?? "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ingredient = homeIngredients[indexPath.row]
        
        let ingredientDetailsView = HomeIngredientDetailsView()
        
        ingredientDetailsView.populateFields(withIngredient: ingredient)
        
        view.addSubview(ingredientDetailsView)
        
        ingredientDetailsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ingredientDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0),
                                     ingredientDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0),
                                     ingredientDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
                                     ingredientDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0)])
        
        ingredientDetailsView.createButton.setTitle("Change", for: .normal)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func homeIngredientsChanged() {
        if let currentUser = UsersManager.shared.currentLoggedInUser {
            homeIngredients = currentUser.homeIngredients
            
            homeIngredientsTableView.reloadData()
        }
    }
}
