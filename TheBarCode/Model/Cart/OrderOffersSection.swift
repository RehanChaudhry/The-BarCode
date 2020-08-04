//
//  OrderOffersSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 03/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderOfferInfo: NSObject {
    var discount: CGFloat
    var text: String
    
    var isSelected: Bool = false
    
    init(discount: CGFloat, text: String, isSelected: Bool) {
        self.discount = discount
        self.text = text
        self.isSelected = isSelected
    }
    
}

extension OrderOfferInfo {
    static func dummyVouchers() -> [OrderOfferInfo] {
        let none = OrderOfferInfo(discount: 0.0, text: "None", isSelected: false)
        let buyOneGetOne = OrderOfferInfo(discount: 0.0, text: "Buy 1 Get 1 Free", isSelected: false)
        
        return [none, buyOneGetOne]
    }
    
    static func dummyOffers() -> [OrderOfferInfo] {
        let none = OrderOfferInfo(discount: 0.0, text: "None", isSelected: false)
        let buyOneGetOne = OrderOfferInfo(discount: 10.0, text: "10% standard offer discount", isSelected: false)
        
        return [none, buyOneGetOne]
    }
}

class OrderOffersSection: OrderViewModel {
    
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
    
    var items: [OrderOfferInfo]

    init(type: OrderSectionType, items: [OrderOfferInfo]) {
        self.type = type
        self.items = items
    }
}
