//
//  OrderPaymentInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: Payment
class OrderPaymentInfo: NSObject {
    
    var title: String = ""

    var percentage: Int = 0
    var status: String = ""
    var price: Double = 0.0

    init(title: String, percentage: Int, status: String, price: Double) {
        self.title = title
        self.percentage = percentage
        self.status = status
        self.price = price
    }
}

class OrderPaymentInfoSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
           return false
    }
    
    var type: OrderSectionType {
        return .payment
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderPaymentInfo]
    
    init(items: [OrderPaymentInfo]) {
        self.items = items
    }
}
