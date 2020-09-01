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
        
        self.quantity = Int("\(map.JSON["quantity"]!)") ?? 0
        self.unitPrice = Double("\(map.JSON["price"]!)") ?? 0.0
    }
}
