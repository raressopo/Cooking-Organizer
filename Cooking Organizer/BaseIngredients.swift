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
            return .dairy
        } else if vegetables.contains(ingredientName) {
            return .vegetables
        } else if fruits.contains(ingredientName) {
            return .fruits
        } else if bakingAndGrains.contains(ingredientName) {
            return .bakingAndGrains
        } else if spices.contains(ingredientName) {
            return .spices
        } else if meat.contains(ingredientName) {
            return .meat
        } else if fishAndSeafood.contains(ingredientName) {
            return .fishAndSeafood
        } else if condiments.contains(ingredientName) {
            return .condiments
        } else if oils.contains(ingredientName) {
            return .oils
        } else if seasonings.contains(ingredientName) {
            return .seasonings
        } else if sauces.contains(ingredientName) {
            return .sauces
        } else if legumes.contains(ingredientName) {
            return .legumes
        } else if alcohol.contains(ingredientName) {
            return .alcohol
        } else if nuts.contains(ingredientName) {
            return .nuts
        } else if dessertAndSnacks.contains(ingredientName) {
            return .dessetAndSnacks
        } else if beverages.contains(ingredientName) {
            return .beverages
        } else {
            return nil
        }
    }
}
