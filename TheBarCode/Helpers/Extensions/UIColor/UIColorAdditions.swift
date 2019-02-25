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
        let startColor = UIColor("#f6f6f6")
        let endColor = UIColor("#ededed")
        return (startColor, endColor)
    }
    
    static func appSilverColors() -> (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor("#e3e3e3")
        let endColor = UIColor("#9d9d9d")
        return (startColor, endColor)
    }
    
    static func appGoldColors() ->  (startColor: UIColor, endColor:UIColor) {
        let startColor = UIColor.appGreenColor()
        let endColor =  UIColor.appBlueColor()
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
}
