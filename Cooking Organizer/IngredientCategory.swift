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
