//
//  UIFontAdditions.swift
//  StormFiberHotspot
//
//  Created by Mac OS X on 03/04/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

let regularFontName = "Lato-Regular"
let boldFontName = "Lato-Bold"

extension UIFont {
    static func appRegularFontOf(size: CGFloat) -> UIFont {
        let font = UIFont(name: regularFontName, size: size)
        return font!
    }
    
    static func appBoldFontOf(size: CGFloat) -> UIFont {
        let font = UIFont(name: boldFontName, size: size)
        return font!
    }
}
