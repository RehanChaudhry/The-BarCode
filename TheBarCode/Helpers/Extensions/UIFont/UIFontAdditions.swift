//
//  UIFontAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/04/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

let regularFontName = "Lato-Regular"
let boldFontName = "Lato-Bold"
let italicFontName = "Lato-Italic"

extension UIFont {
    static func appRegularFontOf(size: CGFloat) -> UIFont {
        let font = UIFont(name: regularFontName, size: size)
        return font!
    }
    
    static func appBoldFontOf(size: CGFloat) -> UIFont {
        let font = UIFont(name: boldFontName, size: size)
        return font!
    }
    
    static func appItalicFontOf(size: CGFloat) -> UIFont {
        let font = UIFont(name: italicFontName, size: size)
        return font!
    }
}
