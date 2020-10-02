//
//  RecipesTableView.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 02/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

protocol RecipesTableViewDelegate: class {
    func recipeSelectedForSchedule(withRecipe recipe: CookingCalendarRecipe)
}

class RecipesTableView: UIView {
    @IBOutlet var contentView: UIView!

    @IBOutlet weak var recipesTableView: UITableView!
    
    weak var delegate: RecipesTableViewDelegate?
    
    var recipes = [CookingCalendarRecipe]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("RecipesTableView", owner: self, options: nil)
        
        addSubview(contentView)
        contentView.frame = self.bounds
        
        recipesTableView.delegate = self
        recipesTableView.dataSource = self
    }
    
    @IBAction func backgroundDismissPressed(_ sender: Any) {
        removeFromSuperview()
    }
}

extension RecipesTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "recipeCell")
        
        cell.selectionStyle = .none
        cell.textLabel?.text = recipes[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.recipeSelectedForSchedule(withRecipe: recipes[indexPath.row])
        
        removeFromSuperview()
    }
}
