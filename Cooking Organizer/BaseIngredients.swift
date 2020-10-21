//
//  BaseIngredients.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

struct BaseIngredients: Codable {
    let dairy: [String]
    let vegetables: [String]
    let fruits: [String]
    let bakingAndGrains: [String]
    let spices: [String]
    let meat: [String]
    let fishAndSeafood: [String]
    let condiments: [String]
    let oils: [String]
    let seasonings: [String]
    let sauces: [String]
    let legumes: [String]
    let alcohol: [String]
    let nuts: [String]
    let dessertAndSnacks: [String]
    let beverages: [String]
    
    enum CodingKeys: String, CodingKey {
        case dairy
        case vegetables
        case fruits
        case bakingAndGrains = "baking & grains"
        case spices
        case meat
        case fishAndSeafood = "fish & seafood"
        case condiments
        case oils
        case seasonings
        case sauces
        case legumes
        case alcohol
        case nuts
        case dessertAndSnacks = "dessert & snacks"
        case beverages
    }
    
    func ingredientCategoryWith(customIngredient ingredientName: String) -> IngredientCategories? {
        if dairy.contains(ingredientName) {
            return .Dairy
        } else if vegetables.contains(ingredientName) {
            return .Vegetables
        } else if fruits.contains(ingredientName) {
            return .Fruits
        } else if bakingAndGrains.contains(ingredientName) {
            return .BakingAndGrains
        }  else if spices.contains(ingredientName) {
            return .Spices
        } else if meat.contains(ingredientName) {
            return .Meat
        } else if fishAndSeafood.contains(ingredientName) {
            return .FishAndSeafood
        } else if condiments.contains(ingredientName) {
            return .Condiments
        } else if oils.contains(ingredientName) {
            return .Oils
        } else if seasonings.contains(ingredientName) {
            return .Seasonings
        } else if sauces.contains(ingredientName) {
            return .Sauces
        } else if legumes.contains(ingredientName) {
            return .Legumes
        } else if alcohol.contains(ingredientName) {
            return .Alcohol
        } else if nuts.contains(ingredientName) {
            return .Nuts
        } else if dessertAndSnacks.contains(ingredientName) {
            return .DessetAndSnacks
        } else if beverages.contains(ingredientName) {
            return .Beverages
        } else {
            return nil
        }
    }
}
