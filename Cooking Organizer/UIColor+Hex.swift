//
//  UIColor+Hex.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 03/11/2022.
//  Copyright © 2022 Rares Soponar. All rights reserved.
//

import Foundation

extension UIColor {
    
    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func buttonTitleColor() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#C17A03")
    }
    
    static func screenBackground() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#024B3C")
    }
    
    static func imageBorder() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#7C9082")
    }
    
    static func onScreenButton() -> UIColor {
        return UIColor.systemBackground
    }
    
    static func textFieldBackgroundColor() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#88AA8D").withAlphaComponent(0.7)
    }
    
    static func deleteButtonTitleColor() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#D71309")
    }
    
    static func checkbockColor() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#A16702")
    }
    
    static func secondaryButtonColor() -> UIColor {
        return UIColor.hexStringToUIColor(hex: "#845C74")
    }
}
