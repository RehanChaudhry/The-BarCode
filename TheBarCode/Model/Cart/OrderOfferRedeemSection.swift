//
//  OrderOfferRedeemSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 04/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderOfferRedeem: NSObject {
    var title: String = ""
    
    init(title: String) {
        self.title = title
    }
}

class OrderOfferRedeemSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderOfferRedeem]

    init(type: OrderSectionType, items: [OrderOfferRedeem]) {
        self.type = type
        self.items = items
    }
    
}
