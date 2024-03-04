//
//  UIImage+Extensions.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 22.11.2022.
//

import UIKit

extension UIImage {
    
    func thumbImageWithMaxPixelSize(_ maxPixelSize: UInt) -> UIImage? {
        let size = self.size
        if size.width < CGFloat(maxPixelSize) && size.height < CGFloat(maxPixelSize) {
            return self
        }
        
        let widthRatio  = CGFloat(maxPixelSize)  / self.size.width
        let heightRatio = CGFloat(maxPixelSize) / self.size.height
        
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
