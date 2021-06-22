//
//  IntroOption.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import GBDeviceInfo

enum IntroOptionType: String {
    case barFinder = "barFinder",
    fiveADay = "fiveADay",
    liveOffers = "liveOffers",
    reload = "reload",
    credits = "credits"
}

class IntroOption {

    var title: String = ""
    var detail: String = ""
    
    var type: IntroOptionType!
    
    var image: String {
        get {
            switch self.type! {
            case .barFinder:
                let imagePrefix = "login_intro_finder"
                let imagePostfix = self.getImagePostfix()
                return (imagePrefix + imagePostfix)
            case .fiveADay:
                let imagePrefix = "order_and_pay"
                let imagePostfix = self.getImagePostfix()
                return (imagePrefix + imagePostfix)
            case .liveOffers:
                let imagePrefix = "login_intro_reload"
                let imagePostfix = self.getImagePostfix()
                return (imagePrefix + imagePostfix)
            case .reload:
                let imagePrefix = "login_intro_live_offer"
                let imagePostfix = self.getImagePostfix()
                return (imagePrefix + imagePostfix)
            case .credits:
                let imagePrefix = "login_intro_credits"
                let imagePostfix = self.getImagePostfix()
                return (imagePrefix + imagePostfix)
            }
        }
    }
    
        func getImagePostfix() -> String {
        
        let deviceInfo = GBDeviceInfo.deviceInfo()
        
        var imagePostfix = ""
        if deviceInfo!.model == .modeliPhone5 || deviceInfo!.model == .modeliPhone5c || deviceInfo!.model == .modeliPhone5s || deviceInfo!.model == .modeliPhone4S || deviceInfo!.model == .modeliPhoneSE {
            imagePostfix = "_5"
        } else if deviceInfo!.model == .modeliPhone6 || deviceInfo!.model == .modeliPhone6s || deviceInfo!.model == .modeliPhone7 || deviceInfo!.model == .modeliPhone8 {
            imagePostfix = "_7"
        } else if deviceInfo!.model == .modeliPhone6Plus || deviceInfo!.model == .modeliPhone7Plus || deviceInfo!.model == .modeliPhone8Plus || deviceInfo!.model == .modeliPhone6sPlus {
            imagePostfix = "_8plus"
        } else if deviceInfo!.model == .modeliPhoneX {
            imagePostfix = "_x"
        } else {
            imagePostfix = "_xr"
        }
        
        return imagePostfix
    }
    
    init(title: String, detail: String, type: IntroOptionType) {
        self.title = title
        self.detail = detail
        self.type = type
    }

}
