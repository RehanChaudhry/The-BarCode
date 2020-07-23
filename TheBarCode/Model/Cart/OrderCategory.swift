//
//  OrderSection.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

enum OrderType: String {
    case onGoingOrders = "onGoingOrders",
    completedOrders = "completedOrders",
    unknown = "unknown"
}


class OrderCategory {

    var type: OrderType = .unknown
    var orders: [Order] = []

    func getTitle() -> String {
                  
        if type == .onGoingOrders {
             return  "Ongoing Orders"
        } else if type == .completedOrders {
             return "Completed Orders"
         }
         return ""
     }
    
    init(type: OrderType, orders: [Order]) {
        self.type = type
        self.orders = orders
    }
}

extension OrderCategory {
   static func getAllDummyOrders() -> [OrderCategory] {
        
        let Category1 = OrderCategory(type: .onGoingOrders, orders: Order.getOngoingDummyOrders())
        let Category2 = OrderCategory(type: .completedOrders, orders: Order.getCompletedDummyOrders())
        return [Category1, Category2]
    }
}
