//
//  UtilsManager.swift
//  Cooking Organizer
//
//  Created by Rares Soponar on 28/05/2020.
//  Copyright © 2020 Rares Soponar. All rights reserved.
//

import UIKit

class UtilsManager: NSObject {
    static let shared = UtilsManager()
    
    let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
    }
    
    class func resizeImageTo450x450AsData(image: UIImage) -> Data? {
        let size = image.size
        let targetSize = CGSize(width: 450, height: 450)
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let newImage = newImage, let newImageAsData = newImage.jpegData(compressionQuality: 0.0) {
            return newImageAsData
        } else {
            return nil
        }
    }
}
