//
//  EventExternalCTA.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class EventExternalCTA: CoreStoreObject {
    
    var placeholder = Value.Required<String>("placeholder", initial: "")
    var link = Value.Required<String>("link", initial: "")
    
    var event = Relationship.ToOne<Event>("event")
}

extension EventExternalCTA: ImportableObject {
    typealias ImportSource = [String: Any]
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        self.placeholder.value = source["link_text"] as? String ?? ""
        self.link.value = source["link"] as? String ?? ""
    }
}
