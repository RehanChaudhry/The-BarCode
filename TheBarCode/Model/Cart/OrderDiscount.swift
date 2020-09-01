//
//  OrderDiscount.swift
//  TheBarCode
//
//  Created by Mac OS X on 01/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

enum OrderDiscountValueType: String {
    case percent = "percent",
    amount = "amount",
    none = "none"
}

class OrderDiscount: Mappable {
    
    var id: String = ""
    var text: String = ""
    
    var value: Double = 0.0
    
    var valueTypeRaw: String = ""
    var typeRaw: String = ""
    
    var valueType: OrderDiscountValueType {
        return OrderDiscountValueType(rawValue: self.valueTypeRaw) ?? .none
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        
        self.text <- map["text"]
        
        self.value <- map["value"]
        
        self.valueTypeRaw <- map["value_type"]
        self.typeRaw <- map["type"]
    }
}
