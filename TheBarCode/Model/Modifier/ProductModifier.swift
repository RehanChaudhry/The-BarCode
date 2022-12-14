//
//  ProductModifier.swift
//  TheBarCode
//
//  Created by Mac OS X on 21/12/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductModifier: Mappable {
    
    var id: String = ""
    var name: String = ""
        
    var price: Double = 0.0
    
    var quantity: Int = 0
    
    var isSelected: Bool = false
    
    var total: Double {
        get {
            return Double(quantity) * price
        }
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        
        self.name <- map["name"]
        self.price <- map["price"]
        
        if let quantity = map.JSON["quantity"] as? Int  {
            self.quantity = quantity
            self.isSelected = quantity > 0
        }
    }
    
}
