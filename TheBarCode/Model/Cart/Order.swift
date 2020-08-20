//
//  Order.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation
import ObjectMapper

enum OrderStatus: String {
    case received = "received",
    inProgress = "inProgress",
    completed = "completed",
    other = "other"
}

class Order: Mappable {
    
    var orderNo: String = ""
    var barName: String = ""
    var barId: String = ""
    var price: String = ""
    var status: OrderStatus =  .other
    
    var orderItems: [OrderItem] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.barId = "\(map.JSON["establishment_id"]!)"
        self.barName <- map["establishment.title"]
        
        self.orderItems <- map["menuItems"]
        
        if let _ = map.JSON["order_id"] as? String {
            self.orderNo = "\(map.JSON["order_id"]!)"
        } else if let _ = map.JSON["order_id"] as? Int {
            self.orderNo = "\(map.JSON["order_id"]!)"
        }
    }
    
    
    init(orderNo: String, barName: String, barId: String, price: String, status: OrderStatus, orderItems: [OrderItem]) {
        self.orderNo = orderNo
        self.barName = barName
        self.barId = barId
        self.price = price
        self.status = status
        self.orderItems = orderItems
    }
    
}


extension Order {
    
    static func getOngoingDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "823488234", barName: "Albert's Schloss", barId: "1", price: "£ 23.00", status: .received, orderItems: OrderItem.getOrderItemList2())
        let order2 = Order(orderNo: "74737473", barName: "The Blue Bar at The Berkeley", barId: "2", price: "£ 14.00", status: .inProgress, orderItems: OrderItem.getOrderItemList1())
        return [order1, order2]

    }
    
    static func getCompletedDummyOrders() -> [Order] {
        let order1 = Order(orderNo: "434267378", barName: "Neighbourhood",barId: "3", price: "£ 32.00", status: .completed, orderItems: OrderItem.getOrderItemList2())
        return [order1]

      }
    
    static func getMyCartDummyOrders() ->  [Order] {
        
        let order1 = Order(orderNo: "823488234", barName: "Albert's Schloss", barId: "1", price: "£ 22.00", status: .received, orderItems: OrderItem.getOrderItemList2())
        let order2 = Order(orderNo: "74737473", barName: "The Blue Bar at The Berkeley", barId: "4", price: "£ 12.00", status: .inProgress,  orderItems: OrderItem.getOrderItemList1())
        return [order1, order2]
    }
}

