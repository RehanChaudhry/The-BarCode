//
//  Bar.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class Bar: Explore {
    
    let fiveADayDeal = Relationship.ToManyOrdered<Deal>("fiveADayDeal", inverse: { $0.establishment })
    var activeStandardOffer = Relationship.ToOne<ActiveStandardOffer>("standard_offer")
    
    var events = Relationship.ToManyOrdered<Event>("events", inverse: { $0.bar })
    
    override func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        super.updateInCoreStore(source: source, transaction: transaction)
        
        if let item = source["standard_offer"] as? [String : Any] {
            
            let importedObject =  try! transaction.importObject(Into<ActiveStandardOffer>(), source: item)
            self.activeStandardOffer.value = importedObject
        }
    }
}

