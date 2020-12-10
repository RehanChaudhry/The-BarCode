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
    pending = "pending",
    processing = "processing",
    delivered = "delivered",
    onTheWay = "on the way",
    readyForPickup = "ready for pickup",
    ongoing = "ongoing",
    completed = "completed",
    rejected = "rejected",
    lookingForDriver = "looking for driver",
    readyToDeliver = "ready to deliver",
    other = "other"
}

struct OrderMappingContext: MapContext {
    var type: OrderMappingType
}

enum OrderMappingType: String {
    case cart = "cart", order = "order"
}

class Order: Mappable {
    
    var cartId: String = ""
    var orderNo: String = ""
    var userId: String = ""
    
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
    
    var todayDeliveryStatusRaw: String = ""
    var todayDeliveryStatus: DeliveryStatus {
        get {
            return DeliveryStatus(rawValue: self.todayDeliveryStatusRaw) ?? .unavailable
        }
    }
    
    var globalDeliveryCharges: Double?
    var minDeliveryCharges: Double?
    var maxDeliveryCharges: Double?
    var customDeliveryCharges: Double?
    
    var deliveryCondition: String?
    
    var updatedAtRaw: String = ""
    var updatedAt: Date = Date()
    
    
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
    
    var orderType: OrderType {
        get {
            return OrderType(rawValue: self.orderTypeRaw) ?? .none
        }
    }
    
    var orderTypeRaw: String = OrderType.none.rawValue
    
    var splitPaymentInfo: SplitPaymentInfo?
    
    var establishmentWorldpayClientKey: String? = nil
    
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
            self.deliveryCondition <- map["establishment.delivery_condition"]
            
            self.cartId = "\(map.JSON["id"]!)"
            
            if let _ = map.JSON["order_id"] as? String {
                self.orderNo = "\(map.JSON["order_id"]!)"
            } else if let _ = map.JSON["order_id"] as? Int {
                self.orderNo = "\(map.JSON["order_id"]!)"
            }
            
            self.establishmentDayStatusRaw <- map["establishment.establishment_timings.status"]
            self.isEstablishmentOpen <- map["establishment.establishment_timings.is_bar_open"]
            
            self.todayDeliveryStatusRaw <- map["establishment.today_delivery_timings.status"]
            
        } else if context?.type == .order {
            self.orderNo = "\(map.JSON["id"]!)"
            self.userId = "\(map.JSON["user_id"]!)"
            self.orderItems <- map["menu"]
            
            self.paymentSplit <- map["payment_split"]
            
            self.voucher <- map["voucher"]
            self.offer <- map["offer"]
            
            self.deliveryCharges <- map["delivery_charges"]
            
            self.orderTypeRaw <- map["type"]
        }
        
        self.establishmentWorldpayClientKey <- map["establishment.worldpay_client_key"]
        
        self.updatedAtRaw <- map["updated_at.date"]
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateformatter.timeZone = serverTimeZone
        self.updatedAt = dateformatter.date(from: self.updatedAtRaw) ?? Date()
        
    }
   
}

