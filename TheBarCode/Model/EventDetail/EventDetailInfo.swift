//
//  EventDetailInfo.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class EventDetailInfo: NSObject {
    
    var title: String
    
    var detail: NSAttributedString
    
    var showCallToAction: Bool
    
    var callToActionTitle: String
    
    var iconName: String
    
    init(title: String, detail: NSAttributedString, showCallToAction: Bool, callToActionTitle: String, iconName: String) {
        self.title = title
        self.detail = detail
        self.showCallToAction = showCallToAction
        self.callToActionTitle = callToActionTitle
        self.iconName = iconName
    }
}
