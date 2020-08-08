//
//  UIImageAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

extension UIImage {
    static func from(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        var rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        rect.size = size
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension UIImage {
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
}
