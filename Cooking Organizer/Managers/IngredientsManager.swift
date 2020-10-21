//
//  IngredientsManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class IngredientsManager {
    static let shared = IngredientsManager()
    
    var allProducts: [String] {
        var result = [String]()
        
        if let bIngredients = baseIngredients {
            let allBaseProducts = bIngredients.dairy +
                bIngredients.fruits +
                bIngredients.vegetables +
                bIngredients.bakingAndGrains +
                bIngredients.spices +
                bIngredients.meat +
                bIngredients.fishAndSeafood +
                bIngredients.condiments +
                bIngredients.oils +
                bIngredients.seasonings +
                bIngredients.sauces +
                bIngredients.legumes +
                bIngredients.alcohol +
                bIngredients.nuts +
                bIngredients.dessertAndSnacks +
                bIngredients.beverages
                
            
            result = result + allBaseProducts
        }
        
        let allCustomIngredients = (customIngredients.dairy ?? [String]()) +
            (customIngredients.fruits ?? [String]()) +
            (customIngredients.vegetables ?? [String]()) +
            (customIngredients.bakingAndGrains ?? [String]()) +
            (customIngredients.spices ?? [String]()) +
            (customIngredients.meat ?? [String]()) +
            (customIngredients.fishAndSeafood ?? [String]()) +
            (customIngredients.condiments ?? [String]()) +
            (customIngredients.oils ?? [String]()) +
            (customIngredients.seasonings ?? [String]()) +
            (customIngredients.sauces ?? [String]()) +
            (customIngredients.legumes ?? [String]()) +
            (customIngredients.alcohol ?? [String]()) +
            (customIngredients.nuts ?? [String]()) +
            (customIngredients.dessertAndSnacks ?? [String]()) +
            (customIngredients.beverages ?? [String]())
        
        result = result + allCustomIngredients
        
        return result
    }
    
    var baseIngredients: BaseIngredients?
    var customIngredients = CustomIngredients()
    
    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parseBaseIngredients(jsonData: Data) {
        do {
            baseIngredients = try JSONDecoder().decode(BaseIngredients.self,
                                                       from: jsonData)
        } catch {
            print(error)
        }
    }
    
    func loadLocalBaseIngredients() {
        if let locatData = readLocalFile(forName: "BaseIngredients") {
            self.parseBaseIngredients(jsonData: locatData)
        }
    }
    
    func ingredientCategory(forIngredient ingredient: String) -> IngredientCategories? {
        var category: IngredientCategories?
        
        if let bIngredients = baseIngredients {
            category = bIngredients.ingredientCategoryWith(customIngredient: ingredient)
        }
        
        if category == nil {
            category = customIngredients.ingredientCategoryWith(customIngredient: ingredient)
        }
        
        return category
    }
    
    func addNewCustomIngredients(customIngredient: String, inCategory category: IngredientCategories) {
        switch category {
        case .Dairy:
            customIngredients.dairy = customIngredients.dairy ?? [String]()
            
            customIngredients.dairy?.append(customIngredient)
        case .Vegetables:
            customIngredients.vegetables = customIngredients.vegetables ?? [String]()
            
            customIngredients.vegetables?.append(customIngredient)
        case .Fruits:
            customIngredients.fruits = customIngredients.fruits ?? [String]()
            
            customIngredients.fruits?.append(customIngredient)
        case .BakingAndGrains:
            customIngredients.bakingAndGrains = customIngredients.bakingAndGrains ?? [String]()
            
            customIngredients.bakingAndGrains?.append(customIngredient)
        case .Spices:
            customIngredients.spices = customIngredients.spices ?? [String]()
            
            customIngredients.spices?.append(customIngredient)
        case .Meat:
            customIngredients.meat = customIngredients.meat ?? [String]()
            
            customIngredients.meat?.append(customIngredient)
        case .FishAndSeafood:
            customIngredients.fishAndSeafood = customIngredients.fishAndSeafood ?? [String]()
            
            customIngredients.fishAndSeafood?.append(customIngredient)
        case .Condiments:
            customIngredients.condiments = customIngredients.condiments ?? [String]()
            
            customIngredients.condiments?.append(customIngredient)
        case .Oils:
            customIngredients.oils = customIngredients.oils ?? [String]()
            
            customIngredients.oils?.append(customIngredient)
        case .Seasonings:
            customIngredients.seasonings = customIngredients.seasonings ?? [String]()
            
            customIngredients.seasonings?.append(customIngredient)
        case .Sauces:
            customIngredients.spices = customIngredients.spices ?? [String]()
            
            customIngredients.sauces?.append(customIngredient)
        case .Legumes:
            customIngredients.legumes = customIngredients.legumes ?? [String]()
            
            customIngredients.legumes?.append(customIngredient)
        case .Alcohol:
            customIngredients.alcohol = customIngredients.alcohol ?? [String]()
            
            customIngredients.alcohol?.append(customIngredient)
        case .Nuts:
            customIngredients.nuts = customIngredients.nuts ?? [String]()
            
            customIngredients.nuts?.append(customIngredient)
        case .DessetAndSnacks:
            customIngredients.dessertAndSnacks = customIngredients.dessertAndSnacks ?? [String]()
            
            customIngredients.dessertAndSnacks?.append(customIngredient)
        case .Beverages:
            customIngredients.beverages = customIngredients.beverages ?? [String]()
            
            customIngredients.beverages?.append(customIngredient)
        }
    }
}
