//
//  OrderDeliveryInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: Delivery Section
class OrderDeliveryInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
}

class OrderDeliveryInfoSection: OrderViewModel {
   
    var shouldShowSeparator: Bool {
        return true
    }
    
    var type: OrderSectionType {
        return .deliveryChargesDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderDeliveryInfo]
    
    init(items: [OrderDeliveryInfo]) {
        self.items = items
    }
}
