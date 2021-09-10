//
//  IngredientCategory.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 27/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

public enum IngredientCategories: CaseIterable {
    case dairy
    case vegetables
    case fruits
    case bakingAndGrains
    case spices
    case meat
    case fishAndSeafood
    case condiments
    case oils
    case seasonings
    case sauces
    case legumes
    case alcohol
    case nuts
    case dessetAndSnacks
    case beverages
    
    var index: Int {
        switch self {
        case .dairy:
            return 0
        case .vegetables:
            return 1
        case .fruits:
            return 2
        case .bakingAndGrains:
            return 3
        case .spices:
            return 4
        case .meat:
            return 5
        case .fishAndSeafood:
            return 6
        case .condiments:
            return 7
        case .oils:
            return 8
        case .seasonings:
            return 9
        case .sauces:
            return 10
        case .legumes:
            return 11
        case .alcohol:
            return 12
        case .nuts:
            return 13
        case .dessetAndSnacks:
            return 14
        case .beverages:
            return 15
        }
    }
    
    var string: String {
        switch self {
        case .dairy:
            return "Dairy"
        case .vegetables:
            return "Vegetables"
        case .fruits:
            return "Fruits"
        case .bakingAndGrains:
            return "Baking and Beans"
        case .spices:
            return "Spices"
        case .meat:
            return "Meat"
        case .fishAndSeafood:
            return "Fish and Seafood"
        case .condiments:
            return "Condiments"
        case .oils:
            return "Oils"
        case .seasonings:
            return "Seasonings"
        case .sauces:
            return "Sauces"
        case .legumes:
            return "Legumes"
        case .alcohol:
            return "Alcohol"
        case .nuts:
            return "Nuts"
        case .dessetAndSnacks:
            return "Desserts and Snacks"
        case .beverages:
            return "Beverages"
        }
    }
    
    var dbKeyString: String {
        switch self {
        case .dairy:
            return "dairy"
        case .vegetables:
            return "vegetables"
        case .fruits:
            return "Fruits"
        case .bakingAndGrains:
            return "bakingAndBeans"
        case .spices:
            return "spices"
        case .meat:
            return "meat"
        case .fishAndSeafood:
            return "fishAndSeafood"
        case .condiments:
            return "condiments"
        case .oils:
            return "oils"
        case .seasonings:
            return "seasonings"
        case .sauces:
            return "sauces"
        case .legumes:
            return "legumes"
        case .alcohol:
            return "alcohol"
        case .nuts:
            return "nuts"
        case .dessetAndSnacks:
            return "dessertsAndSnacks"
        case .beverages:
            return "beverages"
        }
    }
}

class IngredientCategory: NSObject {
    class func categoryNameForIndex(index: Int) -> String {
        switch index {
        case IngredientCategories.vegetables.index:
            return "Vegetables"
        case IngredientCategories.fruits.index:
            return "Fruits"
        case IngredientCategories.spices.index:
            return "Spices"
        case IngredientCategories.fishAndSeafood.index:
            return "Fish and Seafood"
        case IngredientCategories.meat.index:
            return "Meat"
        case IngredientCategories.dessetAndSnacks.index:
            return "Dessert and Snacks"
        case IngredientCategories.alcohol.index:
            return "Alcohol"
        case IngredientCategories.beverages.index:
            return "Beverages"
        case IngredientCategories.legumes.index:
            return "Legumes"
        case IngredientCategories.bakingAndGrains.index:
            return "Baking and Grains"
        case IngredientCategories.condiments.index:
            return "Condiments"
        case IngredientCategories.dairy.index:
            return "Dairy"
        case IngredientCategories.oils.index:
            return "Oils"
        case IngredientCategories.sauces.index:
            return "Sauces"
        case IngredientCategories.nuts.index:
            return "Nuts"
        case IngredientCategories.seasonings.index:
            return "Seasonings"
        default:
            return ""
        }
    }
    
    class func categoryIndexForIndex(index: Int) -> Int {
        switch index {
        case IngredientCategories.dairy.index:
            return 0
        case IngredientCategories.vegetables.index:
            return 1
        case IngredientCategories.fruits.index:
            return 2
        case IngredientCategories.bakingAndGrains.index:
            return 3
        case IngredientCategories.spices.index:
            return 4
        case IngredientCategories.meat.index:
            return 5
        case IngredientCategories.fishAndSeafood.index:
            return 6
        case IngredientCategories.condiments.index:
            return 7
        case IngredientCategories.oils.index:
            return 8
        case IngredientCategories.seasonings.index:
            return 9
        case IngredientCategories.sauces.index:
            return 10
        case IngredientCategories.legumes.index:
            return 11
        case IngredientCategories.alcohol.index:
            return 12
        case IngredientCategories.nuts.index:
            return 13
        case IngredientCategories.dessetAndSnacks.index:
            return 14
        case IngredientCategories.beverages.index:
            return 15
        default:
            return -1
        }
    }
}

public enum RecipeCategories: CaseIterable {
    case breakfast
    case lunch
    case beverages
    case appetizers
    case soups
    case salads
    case mainDishesBeef
    case mainDishesPoultry
    case mainDishesPork
    case mainDishesSeafood
    case mainDishesVegetarian
    case mainDishesVegetables
    case desserts
    case breads
    case holidays
    case traditional
    
    var index: Int {
        switch self {
        case .breakfast:
            return 0
        case .lunch:
            return 1
        case .beverages:
            return 2
        case .appetizers:
            return 3
        case .soups:
            return 4
        case .salads:
            return 5
        case .mainDishesBeef:
            return 6
        case .mainDishesPoultry:
            return 7
        case .mainDishesPork:
            return 8
        case .mainDishesSeafood:
            return 9
        case .mainDishesVegetarian:
            return 10
        case .mainDishesVegetables:
            return 11
        case .desserts:
            return 12
        case .breads:
            return 13
        case .holidays:
            return 14
        case .traditional:
            return 15
        }
    }
    
    var string: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .beverages:
            return "Beverages"
        case .appetizers:
            return "Appetizers"
        case .soups:
            return "Soups"
        case .salads:
            return "Salads"
        case .mainDishesBeef:
            return "Main Dishes: Beef"
        case .mainDishesPoultry:
            return "Main Dishes: Poultry"
        case .mainDishesPork:
            return "Main Dishes: Pork"
        case .mainDishesSeafood:
            return "Main Dishes: Seafood"
        case .mainDishesVegetarian:
            return "Main Dishes: Vegetarian"
        case .mainDishesVegetables:
            return "Main Dishes: Vegetables"
        case .desserts:
            return "Desserts"
        case .breads:
            return "Breads"
        case .holidays:
            return "Holidays"
        case .traditional:
            return "Traditional"
        }
    }
}

class RecipeCategory: NSObject {
    class func categoryNameForIndex(index: Int) -> String {
        switch index {
        case RecipeCategories.breakfast.index:
            return "Breakfast"
        case RecipeCategories.lunch.index:
            return "Lunch"
        case RecipeCategories.beverages.index:
            return "Beverages"
        case RecipeCategories.appetizers.index:
            return "Appetizers"
        case RecipeCategories.soups.index:
            return "Soups"
        case RecipeCategories.salads.index:
            return "Salads"
        case RecipeCategories.mainDishesBeef.index:
            return "Main Dishes: Beef"
        case RecipeCategories.mainDishesPoultry.index:
            return "Main Dishes: Poultry"
        case RecipeCategories.mainDishesPork.index:
            return "Main Dishes: Pork"
        case RecipeCategories.mainDishesSeafood.index:
            return "Main Dishes: Seafood"
        case RecipeCategories.mainDishesVegetarian.index:
            return "Main Dishes: Vegetarian"
        case RecipeCategories.mainDishesVegetables.index:
            return "Main Dishes: Vegetables"
        case RecipeCategories.desserts.index:
            return "Desserts"
        case RecipeCategories.breads.index:
            return "Breads"
        case RecipeCategories.holidays.index:
            return "Holidays"
        case RecipeCategories.traditional.index:
            return "Traditional"
        default:
            return ""
        }
    }
    
    class func categoryIndexForIndex(index: Int) -> Int {
        switch index {
        case RecipeCategories.breakfast.index:
            return 0
        case RecipeCategories.lunch.index:
            return 1
        case RecipeCategories.beverages.index:
            return 2
        case RecipeCategories.appetizers.index:
            return 3
        case RecipeCategories.soups.index:
            return 4
        case RecipeCategories.salads.index:
            return 5
        case RecipeCategories.mainDishesBeef.index:
            return 6
        case RecipeCategories.mainDishesPoultry.index:
            return 7
        case RecipeCategories.mainDishesPork.index:
            return 8
        case RecipeCategories.mainDishesSeafood.index:
            return 9
        case RecipeCategories.mainDishesVegetarian.index:
            return 10
        case RecipeCategories.mainDishesVegetables.index:
            return 11
        case RecipeCategories.desserts.index:
            return 12
        case RecipeCategories.breads.index:
            return 13
        case RecipeCategories.holidays.index:
            return 14
        case RecipeCategories.traditional.index:
            return 15
        default:
            return -1
        }
    }
}
