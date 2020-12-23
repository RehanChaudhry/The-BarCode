//
//  ProductModifierGroup.swift
//  TheBarCode
//
//  Created by Mac OS X on 21/12/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductModifierGroup: Mappable {

    var id: String = ""
    var name: String = ""
    
    var price: Double = 0.0
    
    var min: Int = 0
    var max: Int = 0
    
    var multiSelectMax: Int = 1
    
    var modifiers: [ProductModifier] = []
    
    var selectedModifiersCount: Int {
        get {
            return self.modifiers.filter({$0.isSelected}).count
        }
    }
    
    var selectedModifiersQuantity: Int {
        get {
            let totalSelectedQuantity = self.modifiers.reduce(0) { (quantity, modifier) -> Int in
                return quantity + (modifier.isSelected ? modifier.quantity : 0)
            }
            return totalSelectedQuantity
        }
    }
    
    var isRequired: Bool {
        get {
            return self.min >= 1
        }
    }
    
    var isMultiSelectionAllowed: Bool {
        get {
            return self.max > 1
        }
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        
        self.name <- map["name"]
        self.price <- map["price"]
        
        self.min <- map["min"]
        self.max <- map["max"]
        
        self.multiSelectMax <- map["multi_max"]
        
        self.modifiers <- map["modifiers"]
        
    }
    
    func unselectAllModifiersForSingleSelection() {
        if !self.isMultiSelectionAllowed {
            for item in self.modifiers {
                item.isSelected = false
                item.quantity = 0
            }
        }
    }
    
}
