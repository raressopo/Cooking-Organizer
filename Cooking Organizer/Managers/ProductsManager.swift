//
//  ProductsManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 19/10/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class ProductsManager {
    static let shared = ProductsManager()
    
    var allProducts = [String]()
    var products: Products?
    
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
    
    private func parse(jsonData: Data) {
        do {
            products = try JSONDecoder().decode(Products.self,
                                                from: jsonData)
            
            if let products = products {
                var allProductsFromJSON = products.diaryProducts
                allProductsFromJSON.append(contentsOf: products.vegetablesProducts)
                
                allProducts = allProductsFromJSON
            }
            
        } catch {
            print(error)
        }
    }
    
    func loadLocalBaseIngredients() {
        if let locatData = readLocalFile(forName: "Products") {
            self.parse(jsonData: locatData)
        }
    }
}
