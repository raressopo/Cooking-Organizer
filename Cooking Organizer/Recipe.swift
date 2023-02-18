//
//  Recipe.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/06/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class Recipe: Codable {
    let id: String
    
    var categories: String?
    var cookingTime: String?
    var dificulty: String?
    var imageData: String?
    var name: String?
    var portions: Int?
    
    var cookingDates: [String]?
    var ingredients: [NewRecipeIngredient]?
    var steps: [String]?
    
    var ingredientsCountAsString: String {
        if let ingredientsCount = ingredients?.count {
            return "\(ingredientsCount)"
        } else {
            return "\(0)"
        }
    }
    
    var cookingDatesAsDates: [Date] {
        var finalDates = [Date]()
        
        if let dates = cookingDates {
            for cookingDate in dates {
                if let finalDate = UtilsManager.shared.dateFormatter.date(from: cookingDate) {
                    finalDates.append(finalDate)
                }
            }
        }
        
        return finalDates
    }
    
    var cookingTimeHours: Int {
        if let cookingTimeString = cookingTime {
            let stringComponents = cookingTimeString.components(separatedBy: " ")
            
            return Int(stringComponents[0]) ?? 0
        } else {
            return 0
        }
    }
    
    var cookingTimeMinutes: Int {
        if let cookingTimeString = cookingTime {
            let stringComponents = cookingTimeString.components(separatedBy: " ")
            
            return Int(stringComponents[2]) ?? 0
        } else {
            return 0
        }
    }
    
    var lastCookingDate: Date? {
        if cookingDatesAsDates.isEmpty {
            return nil
        } else {
            let sortedDates = cookingDatesAsDates.sorted(by: { $0.compare($1) == .orderedDescending})
            
            return sortedDates.first
        }
    }
    
    var formattedCookingTime: String? {
        if cookingTimeHours == 0 && cookingTimeMinutes != 0 {
            return "\(cookingTimeMinutes) minutes"
        } else if cookingTimeHours != 0 && cookingTimeMinutes == 0 {
            return "\(cookingTimeHours) hours"
        } else {
            return cookingTime
        }
    }
    
    var recipeCategories: [RecipeCategories] {
        var originalRecipeCategories = [RecipeCategories]()
        
        if let originalCategories = self.categories {
            RecipeCategories.allCases.forEach({
                if originalCategories.contains($0.string) {
                    originalRecipeCategories.append($0)
                }
            })
        }
        
        return originalRecipeCategories
    }
    
    var recipeImage: UIImage? {
        guard let imageData = self.imageData else { return nil }
        
        let dataDecode = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters)
        
        if let imageAsData = dataDecode {
            let decodedImage = UIImage(data: imageAsData)
            
            return decodedImage
        } else {
            return nil
        }
    }
}

class ChangedRecipe {
    var categories: String?
    var cookingTime: String?
    var dificulty: String?
    var imageData: String?
    var name: String?
    var cookingDates: [String]?
    var portions: Int = 0
    
    var ingredients: [NewRecipeIngredient]?
    var steps: [String]?
}

struct CookingCalendarRecipe {
    var name: String
    var id: String
    var cookingDates: [String]
}
