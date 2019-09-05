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
    
    static func appSearchScopeYellowColor() -> UIColor {
        return UIColor("#ffb73b")
    }
    
    static func appSearchScopeYellowSelectedColor() -> UIColor {
        return UIColor("#ffa200")
    }
    
    static func appSearchScopeGreenColor() -> UIColor {
        return UIColor("#00c799")
    }
    
    static func appSearchScopeGreenSelectedColor() -> UIColor {
        return UIColor("#00b58b")
    }
    
    static func appSearchScopePurpleColor() -> UIColor {
        return UIColor("#b46edd")
    }
    
    static func appSearchScopePurpleSelectedColor() -> UIColor {
        return UIColor("#a749de")
    }
    
    static func appSearchScopePinkColor() -> UIColor {
        return UIColor("#ff2f9e")
    }
    
    static func appSearchScopePinkSelectedColor() -> UIColor {
        return UIColor("#ff0088")
    }
    
    static func appSearchScopeBlueColor() -> UIColor {
        return UIColor("#00c5df")
    }
    
    static func appSearchScopeBlueSelectedColor() -> UIColor {
        return UIColor("#00a9bf")
    }
    
    static func appSearchScopeOrangeColor() -> UIColor {
        return UIColor("#ec6623")
    }
    
    static func appSearchScopeOrangeSelectedColor() -> UIColor {
        return UIColor("#ed4f00")
    }

}
