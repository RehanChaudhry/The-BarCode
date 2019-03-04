//
//  ActiveStandardOffer.swift
//  TheBarCode
//
//  Created by Aasna on 20/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore


class ActiveStandardOffer: CoreStoreObject {

    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    var tierId = Value.Required<String>("tier_id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var discountValue = Value.Required<String>("discount_Value", initial: "")
    var typeRaw = Value.Required<String>("type", initial: "")
    
    var type: StandardOfferType {
        get {
            return StandardOfferType(rawValue: self.typeRaw.value) ?? .other
        }
    }
    
    var displayValue: String {
        get {
            return "Get \(self.discountValue.value)% off your first round"
        }
    }
    
    var bar = Relationship.ToManyOrdered<Bar>("bar", inverse: { $0.activeStandardOffer })
    
}


extension ActiveStandardOffer: ImportableUniqueObject {
    
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
        self.establishmentId.value = "\(source["establishment_id"]!)"
        self.tierId.value = "\(source["tier_id"]!)"
        self.typeRaw.value = "\(source["tier_id"]!)"
        self.title.value = source["title"]  as! String
        self.discountValue.value = "\(source["value"]!)"
    }
}
