//
//  OrderOfferDiscountSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 04/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderOfferDiscountInfo: NSObject {
    var title: String = ""
    var value: Double = 0.0
    
    var isHeading: Bool = false
    
    init(title: String, value: Double, isHeading: Bool) {
        self.title = title
        self.value = value
        
        self.isHeading = isHeading
    }
}

class OrderOfferDiscountSection: OrderViewModel {
    
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

    var items: [OrderOfferDiscountInfo]

    init(type: OrderSectionType, items: [OrderOfferDiscountInfo]) {
        self.type = type
        self.items = items
    }
}
