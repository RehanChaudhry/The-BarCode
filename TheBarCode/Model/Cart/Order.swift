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
    
    var total: Double = 0.0
    
    var status: OrderStatus {
        return OrderStatus(rawValue: self.statusRaw) ?? .other
    }
    
    var statusRaw: String = OrderStatus.other.rawValue
    
    var orderItems: [OrderItem] = []
    
    var paymentSplit: [PaymentSplit] = []
    
    var voucher: OrderDiscount?
    var offer: OrderDiscount?
    
    var deliveryCharges: Double = 0.0

    var isDeliveryAvailable: Bool = false
    var isCurrentlyDeliveryDisabled: Bool = false
    var isGlobalDeliveryAllowed: Bool = false
    
    var globalDeliveryCharges: Double?
    var minDeliveryCharges: Double?
    var maxDeliveryCharges: Double?
    var customDeliveryCharges: Double?
        
    var establishmentDayStatus: EstablishmentOpenStatus {
        get {
            return EstablishmentOpenStatus(rawValue: self.establishmentDayStatusRaw) ?? .closed
        }
    }
    
    var establishmentDayStatusRaw: String = ""
    
    var isEstablishmentOpen: Bool = false
    
    var isClosed: Bool {
        get {
            if establishmentDayStatus == .closed {
                return true
            } else {
                return !self.isEstablishmentOpen
            }
        }
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.barId = "\(map.JSON["establishment_id"]!)"
        self.barName <- map["establishment.title"]
        
        self.statusRaw <- map["status"]
        
        self.total <- map["total"]
        
        let context = map.context as? OrderMappingContext
        
        if context?.type == .cart {
            
            self.orderItems <- map["menuItems"]
            self.isDeliveryAvailable <- map["establishment.is_deliver"]
            self.isCurrentlyDeliveryDisabled <- map["establishment.is_delivery_disable"]
            self.isGlobalDeliveryAllowed <- map["establishment.is_global_delivery"]
            
            self.globalDeliveryCharges <- map["establishment.global_delivery_charges"]
            self.minDeliveryCharges <- map["establishment.min_delivery_charges"]
            self.maxDeliveryCharges <- map["establishment.max_delivery_charges"]
            self.customDeliveryCharges <- map["establishment.custom_delivery_amount"]
            
            if let _ = map.JSON["order_id"] as? String {
                self.orderNo = "\(map.JSON["order_id"]!)"
            } else if let _ = map.JSON["order_id"] as? Int {
                self.orderNo = "\(map.JSON["order_id"]!)"
            }
            
            self.establishmentDayStatusRaw <- map["establishment.establishment_timings.status"]
            self.isEstablishmentOpen <- map["establishment.establishment_timings.is_bar_open"]
            
        } else if context?.type == .order {
            self.orderNo = "\(map.JSON["id"]!)"
            self.orderItems <- map["menu"]
            
            self.paymentSplit <- map["payment_split"]
            
            self.voucher <- map["voucher"]
            self.offer <- map["offer"]
            
            self.deliveryCharges <- map["delivery_charges"]
        }
        
        
    }
   
}

