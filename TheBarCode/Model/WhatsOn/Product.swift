//
//  Product.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class Product: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    
    var image = Value.Required<String>("image", initial: "")
    
    var name = Value.Required<String>("name", initial: "")
    var detail = Value.Required<String>("desc", initial: "")
    
    var categoryId = Value.Required<String>("category_id", initial: "")
    var categoryName = Value.Required<String>("category_name", initial: "")
    
    var price = Value.Required<String>("price", initial: "")
    var unit = Value.Required<String>("unit", initial: "")
    
    var quantity = Value.Required<Int>("quantity", initial: 0)
    
    var haveModifiers = Value.Required<Bool>("have_modifiers", initial: false)
    
    var cartItemId = Value.Optional<String>("cart_item_id")
    
    var isAddingToCart: Bool = false
    var isRemovingFromCart: Bool = false
}

extension Product: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Product.id)
    }
    
    var uniqueIDValue: String {
        get { return self.id.value }
        set { self.id.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return "\(source["id"]!)"
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.id.value = "\(source["id"]!)"
        self.establishmentId.value = "\(source["establishment_id"]!)"
        
        self.image.value = source["image"] as? String ?? ""
        
        self.name.value = source["name"] as? String ?? ""
        self.detail.value = source["description"] as? String ?? ""
        
        if let _ = source["price"] {
            self.price.value = "\(source["price"]!)"
        } else {
            self.price.value = ""
        }
        
        if let categoryId = (source["category"] as? [String : Any])?["id"] {
            self.categoryId.value = "\(categoryId)"
        } else {
            self.categoryId.value = ""
        }
        
        if let categoryName = (source["category"] as? [String : Any])?["name"] {
            self.categoryName.value = "\(categoryName)"
        } else {
            self.categoryName.value = ""
        }
        
        if let _ = source["quantity"] {
            self.quantity.value = Int("\(source["quantity"]!)") ?? 0
        } else {
            self.quantity.value = 0
        }
        
        if let _ = source["cart_item_id"] {
            self.cartItemId.value = "\(source["cart_item_id"]!)"
        } else {
            self.cartItemId.value = nil
        }
        
        self.haveModifiers.value = source["have_modifiers"] as? Bool ?? false
        
    }
}


