//
//  ThreeDSModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 07/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

struct ThreeDSModelMapContext: MapContext {
    var sessionId: String
}

class ThreeDSModel: Mappable {
    
    var redirectUrl: String = ""
    var secureRequest: String = ""
    var paymentCode: String = ""
    
    var sessionId: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.redirectUrl <- map["data.redirect_url"]
        self.secureRequest <- map["data.secure_request"]
        self.paymentCode <- map["data.payment_code"]
        
        self.sessionId = (map.context as? ThreeDSModelMapContext)?.sessionId ?? ""
    }
    
}
