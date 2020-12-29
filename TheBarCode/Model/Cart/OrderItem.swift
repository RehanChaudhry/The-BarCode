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
    var quantity: Int = 0 {
        didSet {
            self.updateTotal()
        }
    }

    var unitPrice: Double = 0.0
    
//    var modifierGroups: [ProductModifierGroup] = []
    
    //We are using this array directly after creating order
    //In order to avoid saving of groups in db
    var selectedProductModifiers: [ProductModifier] = []
    
    var cartItemId: String = ""
    
    var totalUnitPrice: Double = 0.0
    var totalPrice: Double = 0.0
    
    var barId: String = ""
    
    var isDeleting: Bool = false
    var isUpdating: Bool = false
    var haveModifiers: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func updateTotal() {
        if self.selectedProductModifiers.count > 0 {
            let productPriceTotal = (self.unitPrice * Double(self.quantity))
            let total = self.selectedProductModifiers.reduce(0.0, { (total, productModifier) -> Double in
                return total + productModifier.price * Double(productModifier.quantity)
            })
            
            self.totalUnitPrice = self.unitPrice + total
            self.totalPrice = (total * Double(self.quantity)) + productPriceTotal
        }
//        else if modifierGroups.count > 0 {
//            let productPriceTotal = (self.unitPrice * Double(self.quantity))
//            let groupTotal = self.modifierGroups.reduce(0.0) { (total, group) -> Double in
//                return total + group.modifiers.reduce(0.0) { (groupTotal, modifier) -> Double in
//                    return groupTotal + (modifier.isSelected ? modifier.price * Double(modifier.quantity) : 0.0)
//                }
//            }
//
//            self.totalUnitPrice = self.unitPrice + groupTotal
//            self.totalPrice = (groupTotal * Double(self.quantity)) + productPriceTotal
//        }
        else {
            self.totalUnitPrice = unitPrice
            self.totalPrice = Double(quantity) * unitPrice
        }
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        self.name <- map["name"]
        
        self.unitPrice = Double("\(map.JSON["price"]!)") ?? 0.0
        self.haveModifiers <- map["have_modifiers"]
        
        if let _ = map.JSON["modifiers"] {
            self.selectedProductModifiers <- map["modifiers"]
        }
        
//        if let _ = map.JSON["modifier_groups"] {
//            self.modifierGroups <- map["modifier_groups"]
//        }

        if let _ = map.JSON["cart_item_id"] {
            self.cartItemId = "\(map.JSON["cart_item_id"]!)"
        }
        
        self.quantity = Int("\(map.JSON["quantity"]!)") ?? 0
    }
}
