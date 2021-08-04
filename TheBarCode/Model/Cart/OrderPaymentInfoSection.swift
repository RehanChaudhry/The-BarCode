//
//  OrderPaymentInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

enum PaymentStatus: String {
    case paid = "paid", pay = "pay"
}

class OrderPaymentInfo: NSObject {
    
    var title: String = ""

    var percentage: Double = 0.0
    var statusRaw: String = ""
    var price: Double = 0.0

    var status: PaymentStatus {
        get {
            return PaymentStatus(rawValue: self.statusRaw) ?? .pay
        }
    }
    
    init(title: String, percentage: Double, statusRaw: String, price: Double) {
        self.title = title
        self.percentage = percentage
        self.statusRaw = statusRaw
        
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
