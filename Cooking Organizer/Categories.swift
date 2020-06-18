//
//  IngredientCategory.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 27/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

public enum IngredientCategories: CaseIterable {
    case Vegetables
    case Fruits
    case International
    case Fish
    case Meat
    case Bread
    case Baking
    case Beverages
    case CerealBreakfast
    case CannedGoods
    case Condiments
    case Dairy
    case FrozenFoods
    case PastaRice
    case Snacks
    case Sweets
    case Spices
    
    var index: Int {
        switch self {
        case .Vegetables:
            return 0
        case .Fruits:
            return 1
        case .International:
            return 2
        case .Fish:
            return 3
        case .Meat:
            return 4
        case .Bread:
            return 5
        case .Baking:
            return 6
        case .Beverages:
            return 7
        case .CerealBreakfast:
            return 8
        case .CannedGoods:
            return 9
        case .Condiments:
            return 10
        case .Dairy:
            return 11
        case .FrozenFoods:
            return 12
        case .PastaRice:
            return 13
        case .Snacks:
            return 14
        case .Sweets:
            return 15
        case .Spices:
            return 16
        }
    }
    
    var string: String {
        switch self {
        case .Vegetables:
            return "Vegetables"
        case .Fruits:
            return "Fruits"
        case .International:
            return "International"
        case .Fish:
            return "Fish"
        case .Meat:
            return "Meat"
        case .Bread:
            return "Bread"
        case .Baking:
            return "Baking"
        case .Beverages:
            return "Beverages"
        case .CerealBreakfast:
            return "Cereals / Breakfast"
        case .CannedGoods:
            return "Canned Goods"
        case .Condiments:
            return "Condiments"
        case .Dairy:
            return "Dairy"
        case .FrozenFoods:
            return "Frozen Foods"
        case .PastaRice:
            return "Pasta / Rice"
        case .Snacks:
            return "Snacks"
        case .Sweets:
            return "Sweets"
        case .Spices:
            return "Spices"
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
        case IngredientCategories.International.index:
            return "International"
        case IngredientCategories.Fish.index:
            return "Fish"
        case IngredientCategories.Meat.index:
            return "Meat"
        case IngredientCategories.Bread.index:
            return "Bread"
        case IngredientCategories.Baking.index:
            return "Baking"
        case IngredientCategories.Beverages.index:
            return "Beverages"
        case IngredientCategories.CerealBreakfast.index:
            return "Cereals / Breakfast"
        case IngredientCategories.CannedGoods.index:
            return "Canned Goods"
        case IngredientCategories.Condiments.index:
            return "Condiments"
        case IngredientCategories.Dairy.index:
            return "Dairy"
        case IngredientCategories.FrozenFoods.index:
            return "Frozen Foods"
        case IngredientCategories.PastaRice.index:
            return "Pasta / Rice"
        case IngredientCategories.Snacks.index:
            return "Snacks"
        case IngredientCategories.Sweets.index:
            return "Sweets"
        case IngredientCategories.Spices.index:
            return "Spices"
        default:
            return ""
        }
    }
    
    class func categoryIndexForIndex(index: Int) -> Int {
        switch index {
        case IngredientCategories.Vegetables.index:
            return 0
        case IngredientCategories.Fruits.index:
            return 1
        case IngredientCategories.International.index:
            return 2
        case IngredientCategories.Fish.index:
            return 3
        case IngredientCategories.Meat.index:
            return 4
        case IngredientCategories.Bread.index:
            return 5
        case IngredientCategories.Baking.index:
            return 6
        case IngredientCategories.Beverages.index:
            return 7
        case IngredientCategories.CerealBreakfast.index:
            return 8
        case IngredientCategories.CannedGoods.index:
            return 9
        case IngredientCategories.Condiments.index:
            return 10
        case IngredientCategories.Dairy.index:
            return 11
        case IngredientCategories.FrozenFoods.index:
            return 12
        case IngredientCategories.PastaRice.index:
            return 13
        case IngredientCategories.Snacks.index:
            return 14
        case IngredientCategories.Sweets.index:
            return 15
        case IngredientCategories.Spices.index:
            return 16
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
