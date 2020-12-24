//
//  OrderFood.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation
import ObjectMapper

class OrderItem: Mappable {
    
    var id: String = ""
    var name: String = ""
    var quantity: Int = 0

    var unitPrice: Double = 0.0
    
    var modifierGroups: [ProductModifierGroup] = []
    
    var cartItemId: String = ""
    
    var totalPrice: Double {
        get{
            return Double(quantity) * unitPrice
        }
    }
    
    var barId: String = ""
    
    var isDeleting: Bool = false
    var isUpdating: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        self.name <- map["name"]
        
        if let _ = map.JSON["modifier_groups"] {
            self.modifierGroups <- map["modifier_groups"]
        }

        self.quantity = Int("\(map.JSON["quantity"]!)") ?? 0
        self.unitPrice = Double("\(map.JSON["price"]!)") ?? 0.0
        
        if let _ = map.JSON["cart_item_id"] {
            self.cartItemId = "\(map.JSON["cart_item_id"]!)"
        }
    }
}
