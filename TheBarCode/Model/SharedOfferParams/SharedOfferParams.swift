//
//  SharedOfferParams.swift
//  TheBarCode
//
//  Created by Mac OS X on 08/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class SharedOfferParams {
    
    var referral: String!
    var sharedBy: String!
    var offerId: String!
    var sharedByName: String!
    
    convenience init(referral: String, sharedBy: String, offerId: String, sharedByName: String) {
        self.init()
        
        self.referral = referral
        self.sharedBy = sharedBy
        self.offerId = offerId
        self.sharedByName = sharedByName
    }
    
}
