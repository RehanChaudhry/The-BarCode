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
    
    
    override func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        super.updateInCoreStore(source: source, transaction: transaction)
        
        debugPrint("Standard Offer map here")
            
        if let item = source["standard_offer"] as? [String : Any] {
            let importedObject =  try! transaction.importObject(Into<ActiveStandardOffer>(), source: item)
            self.activeStandardOffer.value = importedObject
        }
    }
}

