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
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
    }
    
    class func resizeImageTo450x450AsData(image: UIImage) -> Data? {
        let size = image.size
        let targetSize = CGSize(width: 450, height: 450)
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
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
    
    class func isSelectedDate(selectedDate: Date, equalToGivenDate date: Date) -> Bool {
        let calendar = Calendar.current
        
        let givenDateDay = calendar.component(.day, from: date)
        let givenDateMonth = calendar.component(.month, from: date)
        let givenDateYear = calendar.component(.year, from: date)
        
        let selectedDateDay = calendar.component(.day, from: selectedDate)
        let selectedDateMonth = calendar.component(.month, from: selectedDate)
        let selectedDateYear = calendar.component(.year, from: selectedDate)
        
        return givenDateDay == selectedDateDay && givenDateMonth == selectedDateMonth && givenDateYear == selectedDateYear
    }
    
    class func isSelectedDate(selectedDate: Date, inFutureOrInPresentToGivenDate date: Date) -> Bool {
        let calendar = Calendar.current
        
        let givenDateDay = calendar.component(.day, from: date)
        let givenDateMonth = calendar.component(.month, from: date)
        let givenDateYear = calendar.component(.year, from: date)
        
        let selectedDateDay = calendar.component(.day, from: selectedDate)
        let selectedDateMonth = calendar.component(.month, from: selectedDate)
        let selectedDateYear = calendar.component(.year, from: selectedDate)
        
        return (selectedDateYear > givenDateYear) ||
            (selectedDateYear == givenDateYear && selectedDateMonth > givenDateMonth) ||
            (selectedDateYear == givenDateYear && selectedDateMonth == givenDateMonth && selectedDateDay >= givenDateDay)
    }
    
    class func isSelectedDate(selectedDate: Date, inPastOrInPresentToGivenDate date: Date) -> Bool {
        let calendar = Calendar.current
        
        let givenDateDay = calendar.component(.day, from: date)
        let givenDateMonth = calendar.component(.month, from: date)
        let givenDateYear = calendar.component(.year, from: date)
        
        let selectedDateDay = calendar.component(.day, from: selectedDate)
        let selectedDateMonth = calendar.component(.month, from: selectedDate)
        let selectedDateYear = calendar.component(.year, from: selectedDate)
        
        return (selectedDateYear < givenDateYear) ||
            (selectedDateYear == givenDateYear && selectedDateMonth < givenDateMonth) ||
            (selectedDateYear == givenDateYear && selectedDateMonth == givenDateMonth && selectedDateDay <= givenDateDay)
    }
    
    class func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String {
        let unreserved = "@"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)!
    }
    
    func stringByRemovingPercentEncodingForRFC3986() -> String {
        let unreserved = "@"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)!.removingPercentEncoding!
    }
}
