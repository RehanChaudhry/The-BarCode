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

    var unitPrice: String = ""
    var totalprice: String = ""
    
    init(name: String, quantity: Int, unitPrice: String, totalprice: String) {
           self.name = name
           self.quantity = quantity
           self.unitPrice = unitPrice
           self.totalprice = totalprice
       }
    
}

extension OrderItem {
    static func getOrderItemList1() -> [OrderItem] {
        let orderItem = OrderItem(name: "Fish & Chips", quantity: 1, unitPrice: "£ 12.00", totalprice: "£ 12.00")
        return [orderItem]
    }
    
    static func getOrderItemList2() -> [OrderItem] {
        let orderItem1 = OrderItem(name: "Lobster Bisque with Bread & Butter", quantity: 2, unitPrice: "£ 6.00", totalprice: "£ 12.00")
        let orderItem2 = OrderItem(name: "Jerk Chicken", quantity: 1, unitPrice: "£ 10.00", totalprice: "£ 10.00")
        return  [orderItem1, orderItem2]
    }
}
