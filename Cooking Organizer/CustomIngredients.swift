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
            return .dairy
        } else if let vegetables = vegetables, vegetables.contains(ingredientName) {
            return .vegetables
        } else if let fruits = fruits, fruits.contains(ingredientName) {
            return .fruits
        } else if let bakingAndGrains = bakingAndGrains, bakingAndGrains.contains(ingredientName) {
            return .bakingAndGrains
        } else if let spices = spices, spices.contains(ingredientName) {
            return .spices
        } else if let meat = meat, meat.contains(ingredientName) {
            return .meat
        } else if let fishAndSeafood = fishAndSeafood, fishAndSeafood.contains(ingredientName) {
            return .fishAndSeafood
        } else if let condiments = condiments, condiments.contains(ingredientName) {
            return .condiments
        } else if let oils = oils, oils.contains(ingredientName) {
            return .oils
        } else if let seasonings = seasonings, seasonings.contains(ingredientName) {
            return .seasonings
        } else if let sauces = sauces, sauces.contains(ingredientName) {
            return .sauces
        } else if let legumes = legumes, legumes.contains(ingredientName) {
            return .legumes
        } else if let alcohol = alcohol, alcohol.contains(ingredientName) {
            return .alcohol
        } else if let nuts = nuts, nuts.contains(ingredientName) {
            return .nuts
        } else if let dessertAndSnacks = dessertAndSnacks, dessertAndSnacks.contains(ingredientName) {
            return .dessetAndSnacks
        } else if let beverages = beverages, beverages.contains(ingredientName) {
            return .beverages
        } else {
            return nil
        }
    }
}
