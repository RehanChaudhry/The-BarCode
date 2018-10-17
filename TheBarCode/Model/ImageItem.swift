//
//  ImageItem.swift
//  TheBarCode
//
//  Created by Aasna Islam on 15/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class ImageItem: CoreStoreObject {
    var url = Value.Required<String>("url", initial: "")
    var name = Value.Required<String>("name", initial: "")
    var explore = Relationship.ToOne<Explore>("explore")

}


extension ImageItem: ImportableObject {
    
    typealias ImportSource = [String: Any]
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        self.url.value = source["url"] as! String
        self.name.value = source["name"] as! String
    }
}
