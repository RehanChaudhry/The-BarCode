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
    processing = "processing",
    delivered = "delivered",
    onTheWay = "on the way",
    readyForPickup = "ready for pickup",
    ongoing = "ongoing",
    completed = "completed",
    other = "other"
}

struct OrderMappingContext: MapContext {
    var type: OrderMappingType
}

enum OrderMappingType: String {
    case cart = "cart", order = "order"
}

class Order: Mappable {
    
    var orderNo: String = ""
    var barName: String = ""
    var barId: String = ""
//    var price: String = ""
    
    var total: Double = 0.0
    
    var status: OrderStatus {
        return OrderStatus(rawValue: self.statusRaw) ?? .other
    }
    
    var statusRaw: String = OrderStatus.other.rawValue
    
    var orderItems: [OrderItem] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.barId = "\(map.JSON["establishment_id"]!)"
        self.barName <- map["establishment.title"]
        
        self.statusRaw <- map["status"]
        self.orderItems <- map["menuItems"]
        
        self.total <- map["total"]
        
        let context = map.context as? OrderMappingContext
        
        if context?.type == .cart {
            if let _ = map.JSON["order_id"] as? String {
                self.orderNo = "\(map.JSON["order_id"]!)"
            } else if let _ = map.JSON["order_id"] as? Int {
                self.orderNo = "\(map.JSON["order_id"]!)"
            }
        } else if context?.type == .order {
            self.orderNo = "\(map.JSON["id"]!)"
        }
        
        
    }
   
}

