//
//  Offer.swift
//  TheBarCode
//
//  Created by Aasna Islam on 16/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore



class Offer: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    
    var typeRaw = Value.Required<String>("type", initial: "")
    
    var type: OfferType {
        get {
            return OfferType(rawValue: self.typeRaw.value) ?? .unknown
        }
    }
    var deal = Relationship.ToManyOrdered<Deal>("deals", inverse: {$0.offer})
}


extension Offer: ImportableUniqueObject {
    
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
        
        self.title.value = source["title"] as! String
        self.typeRaw.value = source["title"] as! String

//        if let items = source["deals"] as? [[String : Any]] {
//            let importedObjects = try! transaction.importObjects(Into<ImageItem>(), sourceArray: items)
//
//            if !importedObjects.isEmpty {
//                self.images.value = importedObjects
//            }
//        }

    }
}
