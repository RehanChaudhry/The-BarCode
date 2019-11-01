//
//  SharedEventParams.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class SharedEventParams {
    
    var referral: String!
    var sharedBy: String!
    var eventId: String!
    var sharedByName: String!
    
    convenience init(referral: String, sharedBy: String, eventId: String, sharedByName: String) {
        self.init()
        
        self.referral = referral
        self.sharedBy = sharedBy
        self.eventId = eventId
        self.sharedByName = sharedByName
    }
    
}
