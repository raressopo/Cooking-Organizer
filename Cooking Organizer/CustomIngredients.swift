//
//  CustomIngredients.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class CustomIngredients: Codable {
    var dairy: [String]?
    var vegetables: [String]?
    var fruits: [String]?
    var bakingAndGrains: [String]?
    var spices: [String]?
    var meat: [String]?
    var fishAndSeafood: [String]?
    var condiments: [String]?
    var oils: [String]?
    var seasonings: [String]?
    var sauces: [String]?
    var legumes: [String]?
    var alcohol: [String]?
    var nuts: [String]?
    var dessertAndSnacks: [String]?
    var beverages: [String]?
    
    func ingredientCategoryWith(customIngredient ingredientName: String) -> IngredientCategories? {
        if let dairy = dairy, dairy.contains(ingredientName) {
            return .Dairy
        } else if let vegetables = vegetables, vegetables.contains(ingredientName) {
            return .Vegetables
        } else if let fruits = fruits, fruits.contains(ingredientName) {
            return .Fruits
        } else if let bakingAndGrains = bakingAndGrains, bakingAndGrains.contains(ingredientName) {
            return .BakingAndGrains
        }  else if let spices = spices, spices.contains(ingredientName) {
            return .Spices
        } else if let meat = meat, meat.contains(ingredientName) {
            return .Meat
        } else if let fishAndSeafood = fishAndSeafood, fishAndSeafood.contains(ingredientName) {
            return .FishAndSeafood
        } else if let condiments = condiments, condiments.contains(ingredientName) {
            return .Condiments
        } else if let oils = oils, oils.contains(ingredientName) {
            return .Oils
        } else if let seasonings = seasonings, seasonings.contains(ingredientName) {
            return .Seasonings
        } else if let sauces = sauces, sauces.contains(ingredientName) {
            return .Sauces
        } else if let legumes = legumes, legumes.contains(ingredientName) {
            return .Legumes
        } else if let alcohol = alcohol, alcohol.contains(ingredientName) {
            return .Alcohol
        } else if let nuts = nuts, nuts.contains(ingredientName) {
            return .Nuts
        } else if let dessertAndSnacks = dessertAndSnacks, dessertAndSnacks.contains(ingredientName) {
            return .DessetAndSnacks
        } else if let beverages = beverages, beverages.contains(ingredientName) {
            return .Beverages
        } else {
            return nil
        }
    }
}
