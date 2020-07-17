//
//  Order.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

enum OrderStatus: String {
    case received = "received",
    inProgress = "inProgress",
    completed = "completed",
    other = "other"
}

class Order {

    var orderNo: String = ""
    var barName: String = ""

    var price: String = ""
    var status: OrderStatus =  .other
    
    init(orderNo: String, barName: String, price: String, status: OrderStatus) {
           self.orderNo = orderNo
           self.barName = barName
           self.price = price
           self.status = status
       }
    
}


extension Order {
    
    static func getOngoingDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "ORDER NO. 823488234", barName: "Albert's Schloss", price: "£ 23.00", status: .received)
        let order2 = Order(orderNo: "ORDER NO. 823488234", barName: "The Blue Bar at The Berkeley", price: "£ 14.00", status: .inProgress)
        return [order1, order2]

    }
    
    static func getCompletedDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "ORDER NO. 823488234", barName: "Neighbourhood", price: "£ 32.00", status: .completed)
        return [order1]

      }
}

