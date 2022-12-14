//
//  UIColorAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

extension UIColor {
    static func appBlueColor() -> UIColor {
        return UIColor("#00E3FF")
    }
    
    static func appGrayColor() -> UIColor {
        return UIColor("#B7B7B7")
    }
    
    static func appDarkGrayColor() -> UIColor {
        return UIColor("#494949")
    }
    
    static func appBgSecondaryGrayColor() -> UIColor {
        return UIColor("#2B2B2B")
    }
    
    static func appBgGrayColor() -> UIColor {
        return UIColor("#2C2C2C")
    }
    
    static func appFieldBottomBorderColor() -> UIColor {
        return UIColor("#727272")
    }
    
    static func appNavBarGrayColor() -> UIColor {
        return UIColor("#1C1C1C")
    }
    
    static func appGreenColor() -> UIColor {
        return UIColor("#69FF97")
    }
    
    static func appBlackColor() -> UIColor {
        return UIColor("#000000")
    }
    
    static func appRedColor() -> UIColor {
        return UIColor("#FF3B30")
    }
    
    static func appPurpleColor() -> UIColor {
        return UIColor("#8200FF")
    }
    
    static func appGradientGrayStart() -> UIColor {
        return UIColor("#444444")
    }
    
    static func appGradientGrayEnd() -> UIColor {
        return UIColor("#333333")
    }
    
    static func appLightGrayColor() -> UIColor {
        return UIColor("#CCCCCC")
    }
    
    static func appSnackBarOrangeColor() -> UIColor {
        return UIColor("#FB8900")
    }
    
    static func appSnackBarRedColor() -> UIColor {
        return UIColor("#FF002C")
    }
    
    static func appRedeemedGreyColor() -> UIColor {
        return UIColor("#DCDCDC")
    }

 
    static func appBronzeColors() -> (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor.appGreenColor()
        let endColor =  UIColor.appBlueColor()
        return (startColor, endColor)
    }
    
    static func appSilverColors() -> (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor("#c08fed")
        let endColor =  UIColor("#8a45c9")
        return (startColor, endColor)
    }
    
    static func appGoldColors() ->  (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor("#4d82ca")
        let endColor =  UIColor("#9fc5f8")
        return (startColor, endColor)
    }
    
    static func appPlatinumColors() ->  (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor("#8c1b01")
        let endColor = UIColor("#d08923")
        return (startColor, endColor)
    }
    
    static func appDefaultColors() ->  (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor.appGreenColor()
        let endColor =  UIColor.appBlueColor()
        return (startColor, endColor)
    }
    
    static func appStatusButtonOpenColor() -> UIColor {
        return UIColor("#7C7D7D")
    }
    
    static func appStatusButtonColor() -> UIColor {
        return UIColor("#F0F0F0")
    }
    
    static func appSearchScopeBarsColor() -> UIColor {
        return UIColor("#bad3ca")
    }
    
    static func appSearchScopeBarsSelectedColor() -> UIColor {
        return UIColor("#95a9a2")
    }
    
    static func appSearchScopeDeliveryColor() -> UIColor {
        return UIColor("#F6DEB6")
    }
    
    static func appSearchScopeDeliverySelectedColor() -> UIColor {
        return UIColor("#F0C57F")
    }
    
    static func appSearchScopeDealsColor() -> UIColor {
        return UIColor("#a3ffcf")
    }
    
    static func appSearchScopeDealsSelectedColor() -> UIColor {
        return UIColor("#82cca6")
    }
    
    static func appSearchScopeLiveOffersColor() -> UIColor {
        return UIColor("#00ff99")
    }
    
    static func appSearchScopeLiveOffersSelectedColor() -> UIColor {
        return UIColor("#00cc7a")
    }
    
    static func appSearchScopeFoodsColor() -> UIColor {
        return UIColor("#28fff7")
    }
    
    static func appSearchScopeFoodsSelectedColor() -> UIColor {
        return UIColor("#20ccc6")
    }
    
    static func appSearchScopeDrinksColor() -> UIColor {
        return UIColor("#07e1f9")
    }
    
    static func appSearchScopeDrinksSelectedColor() -> UIColor {
        return UIColor("#06b4c7")
    }
    
    static func appSearchScopeEventsColor() -> UIColor {
        return UIColor("#55deed")
    }
    
    static func appSearchScopeEventsSelectedColor() -> UIColor {
        return UIColor("#44b2be")
    }
    
    static func appCartUnSelectedColor() -> UIColor {
        return UIColor("#393A3B")
    }
    
    static func appRadioBgColor() -> UIColor {
        return UIColor("#2A2A2A")
    }
}
