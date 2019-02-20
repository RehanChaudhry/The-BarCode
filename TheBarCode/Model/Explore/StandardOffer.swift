//
//  StandardOffer.swift
//  TheBarCode
//
//  Created by Aasna on 18/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

enum StandardOfferType: String {
    case bronze = "1",
    silver = "2",
    gold = "3",
    platinum = "4",
    other = "other"
}

class StandardOffer: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var discountValue = Value.Required<String>("discount_Value", initial: "")
    var typeRaw = Value.Required<String>("type", initial: "")
    var isSelected = Value.Required<Bool>("is_selected", initial: false)

    var type: StandardOfferType {
        get {
            return StandardOfferType(rawValue: self.typeRaw.value) ?? .other
        }
    }
    
    var displayValue: String {
        get {
            return "Get \(self.discountValue)% OFF your first round".uppercased()
        }
    }
    
}


extension StandardOffer: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Offer.id)
    }
    
    var uniqueIDValue: String {
        get { return self.id.value }
        set { self.id.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        
        return "\(String(describing: source["id"]!))"
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.id.value = "\(source["id"]!)"

        self.title.value = source["title"]  as! String
        self.discountValue.value = "\(source["value"]!)"
        self.typeRaw.value = "\(source["id"]!)"        
    }
}
