//
//  UnitManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 03/11/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import Foundation

class UnitManager {
    // Teaspoon conversions
    class func convertTspToTbsp(tspQuantity: Double) -> Double {
        return tspQuantity * 0.33
    }
    
    class func convertTspToCup(tspQuantity: Double) -> Double {
        return tspQuantity * 0.02
    }
    
    class func convertTspToCups(tspQuantity: Double) -> Double {
        return tspQuantity * 0.02
    }
    
    class func convertTspToMl(tspQuantity: Double) -> Double {
        return tspQuantity * 5
    }
    
    class func convertTspToL(tspQuantity: Double) -> Double {
        return tspQuantity * 0.005
    }
    
    class func convertTspToLb(tspQuantity: Double) -> Double {
        return tspQuantity * 0.01
    }
    
    class func convertTspToOz(tspQuantity: Double) -> Double {
        return tspQuantity * 0.15
    }
    
    class func convertTspToMg(tspQuantity: Double) -> Double {
        return tspQuantity * 4000
    }
    
    class func convertTspToG(tspQuantity: Double) -> Double {
        return tspQuantity * 4
    }
    
    class func convertTspToKg(tspQuantity: Double) -> Double {
        return tspQuantity * 0.004
    }
    
    // Tablespoon conversions
    class func convertTbspToTsp(tbspQuantity: Double) -> Double {
        return tbspQuantity * 3
    }
    
    class func convertTbspToCup(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.06
    }
    
    class func convertTbspToCups(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.06
    }
    
    class func convertTbspToMl(tbspQuantity: Double) -> Double {
        return tbspQuantity * 15
    }
    
    class func convertTbspToL(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.02
    }
    
    class func convertTbspToLb(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.03
    }
    
    class func convertTbspToOz(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.51
    }
    
    class func convertTbspToMg(tbspQuantity: Double) -> Double {
        return tbspQuantity * 14390
    }
    
    class func convertTbspToG(tbspQuantity: Double) -> Double {
        return tbspQuantity * 14.39
    }
    
    class func convertTbspToKg(tbspQuantity: Double) -> Double {
        return tbspQuantity * 0.014
    }
    
    // Cup / Cups conversions
    class func convertCupsToTsp(cupsQuantity: Double) -> Double {
        return cupsQuantity * 50
    }
    
    class func convertCupsToTbsp(cupsQuantity: Double) -> Double {
        return cupsQuantity * 16.67
    }
    
    class func convertCupsToMl(cupsQuantity: Double) -> Double {
        return cupsQuantity * 250
    }
    
    class func convertCupsToL(cupsQuantity: Double) -> Double {
        return cupsQuantity * 0.25
    }
    
    class func convertCupsToLb(cupsQuantity: Double) -> Double {
        return cupsQuantity * 0.53
    }
    
    class func convertCupsToOz(cupsQuantity: Double) -> Double {
        return cupsQuantity * 8.46
    }
    
    class func convertCupsToMg(cupsQuantity: Double) -> Double {
        return cupsQuantity * 240000
    }
    
    class func convertCupsToG(cupsQuantity: Double) -> Double {
        return cupsQuantity * 240
    }
    
    class func convertCupsToKg(cupsQuantity: Double) -> Double {
        return cupsQuantity * 0.24
    }
    
    // Mililiters conversions
    class func convertMlToTsp(mlQuantity: Double) -> Double {
        return mlQuantity * 0.2
    }
    
    class func convertMlToTbsp(mlQuantity: Double) -> Double {
        return mlQuantity * 0.07
    }
    
    class func convertMlToCups(mlQuantity: Double) -> Double {
        return mlQuantity * 0.004
    }
    
    class func convertMlToL(mlQuantity: Double) -> Double {
        return mlQuantity * 0.001
    }
    
    class func convertMlToLb(mlQuantity: Double) -> Double {
        return mlQuantity * 0.002
    }
    
    class func convertMlToOz(mlQuantity: Double) -> Double {
        return mlQuantity * 0.034
    }
    
    class func convertMlToMg(mlQuantity: Double) -> Double {
        return mlQuantity * 960
    }
    
    class func convertMlToG(mlQuantity: Double) -> Double {
        return mlQuantity * 0.96
    }
    
    class func convertMlToKg(mlQuantity: Double) -> Double {
        return mlQuantity * 0.001
    }
    
    // Liters conversions
    class func convertLToTsp(LQuantity: Double) -> Double {
        return LQuantity * 200
    }
    
    class func convertLToTbsp(LQuantity: Double) -> Double {
        return LQuantity * 70
    }
    
    class func convertLToCups(LQuantity: Double) -> Double {
        return LQuantity * 4
    }
    
    class func convertLToMl(LQuantity: Double) -> Double {
        return LQuantity * 1000
    }
    
    class func convertLToLb(LQuantity: Double) -> Double {
        return LQuantity * 2.11
    }
    
    class func convertLToOz(LQuantity: Double) -> Double {
        return LQuantity * 33.82
    }
    
    class func convertLToMg(LQuantity: Double) -> Double {
        return LQuantity * 959000
    }
    
    class func convertLToG(LQuantity: Double) -> Double {
        return LQuantity * 959
    }
    
    class func convertLToKg(LQuantity: Double) -> Double {
        return LQuantity * 0.96
    }
    
    // Pounds conversions
    class func convertLbToTsp(lbQuantity: Double) -> Double {
        return lbQuantity * 94.59
    }
    
    class func convertLbToTbsp(lbQuantity: Double) -> Double {
        return lbQuantity * 31.53
    }
    
    class func convertLbToCups(lbQuantity: Double) -> Double {
        return lbQuantity * 1.89
    }
    
    class func convertLbToMl(lbQuantity: Double) -> Double {
        return lbQuantity * 473
    }
    
    class func convertLbToL(lbQuantity: Double) -> Double {
        return lbQuantity * 0.473
    }
    
    class func convertLbToOz(lbQuantity: Double) -> Double {
        return lbQuantity * 16
    }
    
    class func convertLbToMg(lbQuantity: Double) -> Double {
        return lbQuantity * 454000
    }
    
    class func convertLbToG(lbQuantity: Double) -> Double {
        return lbQuantity * 454
    }
    
    class func convertLbToKg(lbQuantity: Double) -> Double {
        return lbQuantity * 0.454
    }
    
    // Ounces conversions
    class func convertOzToTsp(ozQuantity: Double) -> Double {
        return ozQuantity * 5.91
    }
    
    class func convertOzToTbsp(ozQuantity: Double) -> Double {
        return ozQuantity * 1.97
    }
    
    class func convertOzToCups(ozQuantity: Double) -> Double {
        return ozQuantity * 0.11
    }
    
    class func convertOzToMl(ozQuantity: Double) -> Double {
        return ozQuantity * 473
    }
    
    class func convertOzToL(ozQuantity: Double) -> Double {
        return ozQuantity * 29.5
    }
    
    class func convertOzToLb(ozQuantity: Double) -> Double {
        return ozQuantity * 0.06
    }
    
    class func convertOzToMg(ozQuantity: Double) -> Double {
        return ozQuantity * 28340
    }
    
    class func convertOzToG(ozQuantity: Double) -> Double {
        return ozQuantity * 28.34
    }
    
    class func convertOzToKg(ozQuantity: Double) -> Double {
        return ozQuantity * 0.028
    }
    
    // Miligrams conversions
    class func convertMgToTsp(mgQuantity: Double) -> Double {
        return mgQuantity * 0.0002
    }
    
    class func convertMgToTbsp(mgQuantity: Double) -> Double {
        return mgQuantity * 0.00006
    }
    
    class func convertMgToCups(mgQuantity: Double) -> Double {
        return mgQuantity * 0.0000004
    }
    
    class func convertMgToMl(mgQuantity: Double) -> Double {
        return mgQuantity * 0.001
    }
    
    class func convertMgToL(mgQuantity: Double) -> Double {
        return mgQuantity * 0.000001
    }
    
    class func convertMgToLb(mgQuantity: Double) -> Double {
        return mgQuantity * 0.000002
    }
    
    class func convertMgToOz(mgQuantity: Double) -> Double {
        return mgQuantity * 0.00003
    }
    
    class func convertMgToG(mgQuantity: Double) -> Double {
        return mgQuantity * 0.001
    }
    
    class func convertMgToKg(mgQuantity: Double) -> Double {
        return mgQuantity * 0.000001
    }
    
    // Grams conversions
    class func convertGToTsp(gQuantity: Double) -> Double {
        return gQuantity * 0.2
    }
    
    class func convertGToTbsp(gQuantity: Double) -> Double {
        return gQuantity * 0.069
    }
    
    class func convertGToCups(gQuantity: Double) -> Double {
        return gQuantity * 0.004
    }
    
    class func convertGToMl(gQuantity: Double) -> Double {
        return gQuantity * 1.04
    }
    
    class func convertGToL(gQuantity: Double) -> Double {
        return gQuantity * 0.001
    }
    
    class func convertGToLb(gQuantity: Double) -> Double {
        return gQuantity * 0.0022
    }
    
    class func convertGToOz(gQuantity: Double) -> Double {
        return gQuantity * 0.035
    }
    
    class func convertGToMg(gQuantity: Double) -> Double {
        return gQuantity * 1000
    }
    
    class func convertGToKg(gQuantity: Double) -> Double {
        return gQuantity * 0.001
    }
    
    // Kilograms conversions
    class func convertKgToTsp(kgQuantity: Double) -> Double {
        return kgQuantity * 208
    }
    
    class func convertKgToTbsp(kgQuantity: Double) -> Double {
        return kgQuantity * 69.5
    }
    
    class func convertKgToCups(kgQuantity: Double) -> Double {
        return kgQuantity * 4.1
    }
    
    class func convertKgToMl(kgQuantity: Double) -> Double {
        return kgQuantity * 1042
    }
    
    class func convertKgToL(kgQuantity: Double) -> Double {
        return kgQuantity * 1.042
    }
    
    class func convertKgToLb(kgQuantity: Double) -> Double {
        return kgQuantity * 2.2
    }
    
    class func convertKgToOz(kgQuantity: Double) -> Double {
        return kgQuantity * 35.2
    }
    
    class func convertKgToMg(kgQuantity: Double) -> Double {
        return kgQuantity * 1000000
    }
    
    class func convertKgToG(kgQuantity: Double) -> Double {
        return kgQuantity * 1000
    }
}
