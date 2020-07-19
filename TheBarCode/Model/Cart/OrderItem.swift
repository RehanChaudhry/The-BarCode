//
//  OrderFood.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

class OrderItem {
    
    var name: String = ""
    var quantity: Int = 0

    var unitPrice: Double = 0.0
    
    var totalPrice: Double {
        get{
            return Double(quantity) * unitPrice
        }
    }
    
    init(name: String, quantity: Int, unitPrice: Double) {
           self.name = name
           self.quantity = quantity
           self.unitPrice = unitPrice
       }
    
    
    
}

extension OrderItem {
    static func getOrderItemList1() -> [OrderItem] {
        let orderItem = OrderItem(name: "Fish & Chips", quantity: 1, unitPrice: 12.0)
        return [orderItem]
    }
    
    static func getOrderItemList2() -> [OrderItem] {
        let orderItem1 = OrderItem(name: "Lobster Bisque with Bread & Butter", quantity: 2, unitPrice: 6.0)
        let orderItem2 = OrderItem(name: "Jerk Chicken", quantity: 1, unitPrice: 10.0)
        return  [orderItem1, orderItem2]
    }
}
