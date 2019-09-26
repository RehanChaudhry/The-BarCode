//
//  GMUCustomClusterIconGenerator.swift
//  TheBarCode
//
//  Created by Mac OS X on 23/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class GMUCustomClusterIconGenerator: NSObject, GMUClusterIconGenerator {

    func icon(forSize size: UInt) -> UIImage! {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 12.0),
                          NSAttributedStringKey.foregroundColor : UIColor.white,
                          NSAttributedStringKey.paragraphStyle : paragraphStyle]

        let text = size > 99 ? "99+" : "\(size)"

        let textSize = text.size(withAttributes: attributes)
        let rect = CGRect(x: 0.0, y: 0.0, width: 21.0, height: 21.0)
        
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContext(rect.size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        let backgroundColor = UIColor.clear
        context?.setFillColor(backgroundColor.cgColor)
        context?.fillEllipse(in: rect)
        context?.restoreGState()
        
        UIColor.white.set()
        
        let textRect = rect.insetBy(dx: (rect.size.width - textSize.width) / 2.0, dy: (rect.size.height - textSize.height) / 2.0)
        text.draw(in: textRect.integral, withAttributes: attributes)
        
        let topImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        let bgImage = UIImage(named: "icon_pin_cluster")!
        return self.imageByCombiningImage(firstImage: bgImage, withImage: topImage)
    }
    
    func imageByCombiningImage(firstImage: UIImage, withImage secondImage: UIImage) -> UIImage {
        
        let newImageWidth  = max(firstImage.size.width,  secondImage.size.width )
        let newImageHeight = max(firstImage.size.height, secondImage.size.height)
        let newImageSize = CGSize(width : newImageWidth, height: newImageHeight)

        UIGraphicsBeginImageContextWithOptions(newImageSize, false, UIScreen.main.scale)
        
        let firstImageDrawX  = round((newImageSize.width  - firstImage.size.width  ) / 2)
        let firstImageDrawY  = round((newImageSize.height - firstImage.size.height ) / 2)
        
        let secondImageDrawX = round((newImageSize.width  - secondImage.size.width ) / 2)
        let secondImageDrawY = CGFloat(7.0)
        
        firstImage .draw(at: CGPoint(x: firstImageDrawX,  y: firstImageDrawY))
        secondImage.draw(at: CGPoint(x: secondImageDrawX, y: secondImageDrawY))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return image!
    }
}
