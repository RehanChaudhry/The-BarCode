//
//  OrderDiscountSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: Discount
class OrderDiscountInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
}

class OrderDiscountSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .discountDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderDiscountInfo]
    
    init(items: [OrderDiscountInfo]) {
        self.items = items
    }
    
}
