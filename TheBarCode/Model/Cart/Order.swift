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
    
    var orderItems: [OrderItem] = []
    
    init(orderNo: String, barName: String, price: String, status: OrderStatus, orderItems: [OrderItem]) {
        self.orderNo = orderNo
        self.barName = barName
        self.price = price
        self.status = status
        self.orderItems = orderItems
    }
    
}


extension Order {
    
    static func getOngoingDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "ORDER NO. 823488234", barName: "Albert's Schloss", price: "£ 23.00", status: .received, orderItems: OrderItem.getOrderItemList2())
        let order2 = Order(orderNo: "ORDER NO. 74737473", barName: "The Blue Bar at The Berkeley", price: "£ 14.00", status: .inProgress, orderItems: OrderItem.getOrderItemList1())
        return [order1, order2]

    }
    
    static func getCompletedDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "ORDER NO. 434267378", barName: "Neighbourhood", price: "£ 32.00", status: .completed, orderItems: OrderItem.getOrderItemList2())
        return [order1]

      }
    
    static func getMyCartDummyOrders() ->  [Order] {
        
        let order1 = Order(orderNo: "ORDER NO. 823488234", barName: "Albert's Schloss", price: "£ 22.00", status: .received, orderItems: OrderItem.getOrderItemList2())
        let order2 = Order(orderNo: "ORDER NO. 74737473", barName: "The Blue Bar at The Berkeley", price: "£ 12.00", status: .inProgress,  orderItems: OrderItem.getOrderItemList1())
        return [order1, order2]
    }
}

