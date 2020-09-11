//
//  PaymentSplit.swift
//  TheBarCode
//
//  Created by Mac OS X on 01/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class PaymentSplit: Mappable {
    
    var id: String = ""
    var name: String = ""
    
    var amount: Double = 0.0
    
    var discount: Double = 0.0
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        self.name <- map["name"]
        
        self.amount <- map["amount"]
        
        self.discount <- map["discount"]
    }
    
}
