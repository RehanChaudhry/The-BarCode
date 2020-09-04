//
//  CreditCard.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import Stripe

enum CreditCardType: String {
    case visa = "Visa",
    master = "MasterCard",
    amex = "American Express",
    jcb = "JCB",
    discover = "Discover",
    dinners = "Diners Club",
    uniionPay = "UnionPay",
    unknown = "unknown"
    
    func image() -> UIImage {
        switch self {
        case .visa:
            return STPImageLibrary.visaCardImage()
        case .master:
            return STPImageLibrary.masterCardCardImage()
        case .amex:
            return STPImageLibrary.amexCardImage()
        case .jcb:
            return STPImageLibrary.jcbCardImage()
        case .discover:
            return STPImageLibrary.discoverCardImage()
        case .dinners:
            return STPImageLibrary.dinersClubCardImage()
        case .uniionPay:
            return STPImageLibrary.unionPayCardImage()
        default:
            return STPImageLibrary.unknownCardCardImage()
        }
    }
}

class CreditCard: Mappable {
    
    var type: CreditCardType {
        get {
            return CreditCardType(rawValue: self.typeRaw) ?? .unknown
        }
    }
    
    var typeRaw: String = ""
    
    var cardId: String = ""
    var endingIn: String = ""
    
    var isDeleting: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.typeRaw <- map["type"]
        self.cardId <- map["card_id"]
        self.endingIn <- map["ending_in"]
    }
}
