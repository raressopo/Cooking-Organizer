//
//  IngredientCategory.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 27/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

public enum IngredientCategories: CaseIterable {
    case Dairy
    case Vegetables
    case Fruits
    case BakingAndGrains
    case Spices
    case Meat
    case FishAndSeafood
    case Condiments
    case Oils
    case Seasonings
    case Sauces
    case Legumes
    case Alcohol
    case Nuts
    case DessetAndSnacks
    case Beverages
    
    var index: Int {
        switch self {
        case .Dairy:
            return 0
        case .Vegetables:
            return 1
        case .Fruits:
            return 2
        case .BakingAndGrains:
            return 3
        case .Spices:
            return 4
        case .Meat:
            return 5
        case .FishAndSeafood:
            return 6
        case .Condiments:
            return 7
        case .Oils:
            return 8
        case .Seasonings:
            return 9
        case .Sauces:
            return 10
        case .Legumes:
            return 11
        case .Alcohol:
            return 12
        case .Nuts:
            return 13
        case .DessetAndSnacks:
            return 14
        case .Beverages:
            return 15
        }
    }
    
    var string: String {
        switch self {
        case .Dairy:
            return "Dairy"
        case .Vegetables:
            return "Vegetables"
        case .Fruits:
            return "Fruits"
        case .BakingAndGrains:
            return "Baking and Beans"
        case .Spices:
            return "Spices"
        case .Meat:
            return "Meat"
        case .FishAndSeafood:
            return "Fish and Seafood"
        case .Condiments:
            return "Condiments"
        case .Oils:
            return "Oils"
        case .Seasonings:
            return "Seasonings"
        case .Sauces:
            return "Sauces"
        case .Legumes:
            return "Legumes"
        case .Alcohol:
            return "Alcohol"
        case .Nuts:
            return "Nuts"
        case .DessetAndSnacks:
            return "Desserts and Snacks"
        case .Beverages:
            return "Beverages"
        }
    }
    
    var dbKeyString: String {
        switch self {
        case .Dairy:
            return "dairy"
        case .Vegetables:
            return "vegetables"
        case .Fruits:
            return "Fruits"
        case .BakingAndGrains:
            return "bakingAndBeans"
        case .Spices:
            return "spices"
        case .Meat:
            return "meat"
        case .FishAndSeafood:
            return "fishAndSeafood"
        case .Condiments:
            return "condiments"
        case .Oils:
            return "oils"
        case .Seasonings:
            return "seasonings"
        case .Sauces:
            return "sauces"
        case .Legumes:
            return "legumes"
        case .Alcohol:
            return "alcohol"
        case .Nuts:
            return "nuts"
        case .DessetAndSnacks:
            return "dessertsAndSnacks"
        case .Beverages:
            return "beverages"
        }
    }
}

class IngredientCategory: NSObject {
    class func categoryNameForIndex(index: Int) -> String {
        switch index {
        case IngredientCategories.Vegetables.index:
            return "Vegetables"
        case IngredientCategories.Fruits.index:
            return "Fruits"
        case IngredientCategories.Spices.index:
            return "Spices"
        case IngredientCategories.FishAndSeafood.index:
            return "Fish and Seafood"
        case IngredientCategories.Meat.index:
            return "Meat"
        case IngredientCategories.DessetAndSnacks.index:
            return "Dessert and Snacks"
        case IngredientCategories.Alcohol.index:
            return "Alcohol"
        case IngredientCategories.Beverages.index:
            return "Beverages"
        case IngredientCategories.Legumes.index:
            return "Legumes"
        case IngredientCategories.BakingAndGrains.index:
            return "Baking and Grains"
        case IngredientCategories.Condiments.index:
            return "Condiments"
        case IngredientCategories.Dairy.index:
            return "Dairy"
        case IngredientCategories.Oils.index:
            return "Oils"
        case IngredientCategories.Sauces.index:
            return "Sauces"
        case IngredientCategories.Nuts.index:
            return "Nuts"
        case IngredientCategories.Seasonings.index:
            return "Seasonings"
        default:
            return ""
        }
    }
    
    class func categoryIndexForIndex(index: Int) -> Int {
        switch index {
        case IngredientCategories.Dairy.index:
            return 0
        case IngredientCategories.Vegetables.index:
            return 1
        case IngredientCategories.Fruits.index:
            return 2
        case IngredientCategories.BakingAndGrains.index:
            return 3
        case IngredientCategories.Spices.index:
            return 4
        case IngredientCategories.Meat.index:
            return 5
        case IngredientCategories.FishAndSeafood.index:
            return 6
        case IngredientCategories.Condiments.index:
            return 7
        case IngredientCategories.Oils.index:
            return 8
        case IngredientCategories.Seasonings.index:
            return 9
        case IngredientCategories.Sauces.index:
            return 10
        case IngredientCategories.Legumes.index:
            return 11
        case IngredientCategories.Alcohol.index:
            return 12
        case IngredientCategories.Nuts.index:
            return 13
        case IngredientCategories.DessetAndSnacks.index:
            return 14
        case IngredientCategories.Beverages.index:
            return 15
        default:
            return -1
        }
    }
}

public enum RecipeCategories: CaseIterable {
    case Breakfast
    case Lunch
    case Beverages
    case Appetizers
    case Soups
    case Salads
    case MainDishesBeef
    case MainDishesPoultry
    case MainDishesPork
    case MainDishesSeafood
    case MainDishesVegetarian
    case MainDishesVegetables
    case Desserts
    case Breads
    case Holidays
    case Traditional
    
    var index: Int {
        switch self {
        case .Breakfast:
            return 0
        case .Lunch:
            return 1
        case .Beverages:
            return 2
        case .Appetizers:
            return 3
        case .Soups:
            return 4
        case .Salads:
            return 5
        case .MainDishesBeef:
            return 6
        case .MainDishesPoultry:
            return 7
        case .MainDishesPork:
            return 8
        case .MainDishesSeafood:
            return 9
        case .MainDishesVegetarian:
            return 10
        case .MainDishesVegetables:
            return 11
        case .Desserts:
            return 12
        case .Breads:
            return 13
        case .Holidays:
            return 14
        case .Traditional:
            return 15
        }
    }
    
    var string: String {
        switch self {
        case .Breakfast:
            return "Breakfast"
        case .Lunch:
            return "Lunch"
        case .Beverages:
            return "Beverages"
        case .Appetizers:
            return "Appetizers"
        case .Soups:
            return "Soups"
        case .Salads:
            return "Salads"
        case .MainDishesBeef:
            return "Main Dishes: Beef"
        case .MainDishesPoultry:
            return "Main Dishes: Poultry"
        case .MainDishesPork:
            return "Main Dishes: Pork"
        case .MainDishesSeafood:
            return "Main Dishes: Seafood"
        case .MainDishesVegetarian:
            return "Main Dishes: Vegetarian"
        case .MainDishesVegetables:
            return "Main Dishes: Vegetables"
        case .Desserts:
            return "Desserts"
        case .Breads:
            return "Breads"
        case .Holidays:
            return "Holidays"
        case .Traditional:
            return "Traditional"
        }
    }
}

class RecipeCategory: NSObject {
    class func categoryNameForIndex(index: Int) -> String {
        switch index {
        case RecipeCategories.Breakfast.index:
            return "Breakfast"
        case RecipeCategories.Lunch.index:
            return "Lunch"
        case RecipeCategories.Beverages.index:
            return "Beverages"
        case RecipeCategories.Appetizers.index:
            return "Appetizers"
        case RecipeCategories.Soups.index:
            return "Soups"
        case RecipeCategories.Salads.index:
            return "Salads"
        case RecipeCategories.MainDishesBeef.index:
            return "Main Dishes: Beef"
        case RecipeCategories.MainDishesPoultry.index:
            return "Main Dishes: Poultry"
        case RecipeCategories.MainDishesPork.index:
            return "Main Dishes: Pork"
        case RecipeCategories.MainDishesSeafood.index:
            return "Main Dishes: Seafood"
        case RecipeCategories.MainDishesVegetarian.index:
            return "Main Dishes: Vegetarian"
        case RecipeCategories.MainDishesVegetables.index:
            return "Main Dishes: Vegetables"
        case RecipeCategories.Desserts.index:
            return "Desserts"
        case RecipeCategories.Breads.index:
            return "Breads"
        case RecipeCategories.Holidays.index:
            return "Holidays"
        case RecipeCategories.Traditional.index:
            return "Traditional"
        default:
            return ""
        }
    }
    
    class func categoryIndexForIndex(index: Int) -> Int {
        switch index {
        case RecipeCategories.Breakfast.index:
            return 0
        case RecipeCategories.Lunch.index:
            return 1
        case RecipeCategories.Beverages.index:
            return 2
        case RecipeCategories.Appetizers.index:
            return 3
        case RecipeCategories.Soups.index:
            return 4
        case RecipeCategories.Salads.index:
            return 5
        case RecipeCategories.MainDishesBeef.index:
            return 6
        case RecipeCategories.MainDishesPoultry.index:
            return 7
        case RecipeCategories.MainDishesPork.index:
            return 8
        case RecipeCategories.MainDishesSeafood.index:
            return 9
        case RecipeCategories.MainDishesVegetarian.index:
            return 10
        case RecipeCategories.MainDishesVegetables.index:
            return 11
        case RecipeCategories.Desserts.index:
            return 12
        case RecipeCategories.Breads.index:
            return 13
        case RecipeCategories.Holidays.index:
            return 14
        case RecipeCategories.Traditional.index:
            return 15
        default:
            return -1
        }
    }
}
