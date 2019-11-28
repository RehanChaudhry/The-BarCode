//
//  RedeemingType.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

enum RedeemingType: String {
    case all = "all",
    unlimited = "unlimited",
    limited = "limited"
    
    func title() -> String {
        switch self {
        case .all:
            return "All"
        case .unlimited:
            return "Unlimited"
        case .limited:
            return "Limited"
        }
    }
    
    func icon() -> UIImage {
        switch self {
        case .all:
            return UIImage(named: "icon_all")!
        case .unlimited:
            return UIImage(named: "icon_unlimited")!
        case .limited:
            return UIImage(named: "icon_limited")!
        }
    }
    
    static func allTypes() -> [RedeemingTypeModel] {
        let all = RedeemingTypeModel(type: .all, selected: false)
        let unlimited = RedeemingTypeModel(type: .unlimited, selected: false)
        let limited = RedeemingTypeModel(type: .limited, selected: false)
        return [all, unlimited, limited]
    }
}

class RedeemingTypeModel: NSObject {
    
    var type: RedeemingType
    var selected: Bool
    
    init(type: RedeemingType, selected: Bool) {
        self.type = type
        self.selected = selected
    }
}
