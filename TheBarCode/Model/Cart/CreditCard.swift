//
//  CreditCard.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import SquareInAppPaymentsSDK

enum CreditCardType: String {
    case visa = "visa",
    master = "mastercard",
    maestro = "maestro",
    amex = "amex",
    jcb = "jcb",
    discover = "discover",
    dinners = "diners",
    uniionPay = "union",
    airplus = "airplus",
    dankort = "dankort",
    laser = "laser",
    unknown = "unknown"
    
    static func typeForServer(raw: String) -> String {
        if raw.lowercased().contains(CreditCardType.visa.rawValue.lowercased()) {
            return "visa"
        } else if raw.lowercased().contains(CreditCardType.master.rawValue.lowercased()) {
            return "mastercard"
        } else if raw.lowercased().contains(CreditCardType.amex.rawValue.lowercased()) {
            return "amex"
        } else if raw.lowercased().contains(CreditCardType.jcb.rawValue.lowercased()) {
            return "jcb"
        } else if raw.lowercased().contains(CreditCardType.discover.rawValue.lowercased()) {
            return "discover"
        } else if raw.lowercased().contains(CreditCardType.dinners.rawValue.lowercased()) {
            return "diners"
        } else if raw.lowercased().contains(CreditCardType.uniionPay.rawValue.lowercased()) {
            return "union"
        } else if raw.lowercased().contains(CreditCardType.maestro.rawValue.lowercased()) {
            return "maestro"
        } else if raw.lowercased().contains(CreditCardType.airplus.rawValue.lowercased()) {
            return "airplus"
        } else if raw.lowercased().contains(CreditCardType.dankort.rawValue.lowercased()) {
            return "dankort"
        } else if raw.lowercased().contains(CreditCardType.laser.rawValue.lowercased()) {
            return "laser"
        } else {
            return raw
        }
    }
    
    static func displayableType(raw: String) -> String {
        if raw.lowercased().contains(CreditCardType.visa.rawValue.lowercased()) {
            return "VISA"
        } else if raw.lowercased().contains(CreditCardType.master.rawValue.lowercased()) {
            return "MASTER"
        } else if raw.lowercased().contains(CreditCardType.amex.rawValue.lowercased()) {
            return "AMEX"
        } else if raw.lowercased().contains(CreditCardType.jcb.rawValue.lowercased()) {
            return "JCB"
        } else if raw.lowercased().contains(CreditCardType.discover.rawValue.lowercased()) {
            return "DISCOVER"
        } else if raw.lowercased().contains(CreditCardType.dinners.rawValue.lowercased()) {
            return "DINERS"
        } else if raw.lowercased().contains(CreditCardType.uniionPay.rawValue.lowercased()) {
            return "UNIONPAY"
        } else if raw.lowercased().contains(CreditCardType.maestro.rawValue.lowercased()) {
            return "MAESTRO"
        } else if raw.lowercased().contains(CreditCardType.airplus.rawValue.lowercased()) {
            return "AIRPLUS"
        } else if raw.lowercased().contains(CreditCardType.dankort.rawValue.lowercased()) {
            return "DANKORT"
        } else if raw.lowercased().contains(CreditCardType.laser.rawValue.lowercased()) {
            return "LASER"
        } else {
            return raw
        }
    }
    
    static func iconImage(raw: String) -> UIImage {
        if raw.lowercased().contains(CreditCardType.visa.rawValue.lowercased()) {
            return UIImage(named: "ic_visa")!
        } else if raw.lowercased().contains(CreditCardType.master.rawValue.lowercased()) {
            return UIImage(named: "ic_master")!
        } else if raw.lowercased().contains(CreditCardType.amex.rawValue.lowercased()) {
            return UIImage(named: "ic_amex")!
        } else if raw.lowercased().contains(CreditCardType.jcb.rawValue.lowercased()) {
            return UIImage(named: "ic_jcb")!
        } else if raw.lowercased().contains(CreditCardType.discover.rawValue.lowercased()) {
            return UIImage(named: "ic_discover")!
        } else if raw.lowercased().contains(CreditCardType.dinners.rawValue.lowercased()) {
            return UIImage(named: "ic_diners")!
        } else if raw.lowercased().contains(CreditCardType.uniionPay.rawValue.lowercased()) {
            return UIImage(named: "ic_union_pay")!
        } else if raw.lowercased().contains(CreditCardType.maestro.rawValue.lowercased()) {
            return UIImage(named: "ic_maestro")!
        } else if raw.lowercased().contains(CreditCardType.airplus.rawValue.lowercased()) {
            return UIImage(named: "ic_airplus")!
        } else if raw.lowercased().contains(CreditCardType.dankort.rawValue.lowercased()) {
            return UIImage(named: "ic_dankort")!
        } else if raw.lowercased().contains(CreditCardType.laser.rawValue.lowercased()) {
            return UIImage(named: "ic_laser")!
        } else {
            return UIImage(named: "icon_card")!
        }
    }
    
    func image() -> UIImage {
        switch self {
        case .visa:
            return UIImage(named: "ic_visa")!
        case .master:
            return UIImage(named: "ic_master")!
        case .amex:
            return UIImage(named: "ic_amex")!
        case .jcb:
            return UIImage(named: "ic_jcb")!
        case .discover:
            return UIImage(named: "ic_discover")!
        case .dinners:
            return UIImage(named: "ic_diners")!
        case .uniionPay:
            return UIImage(named: "ic_union_pay")!
        case .maestro:
            return UIImage(named: "ic_maestro")!
        case .airplus:
            return UIImage(named: "ic_airplus")!
        case .dankort:
            return UIImage(named: "ic_dankort")!
        case .laser:
            return UIImage(named: "ic_laser")!
        default:
            return UIImage(named: "icon_card")!
        }
    }
    
    var regex : String {
        switch self {
        case .amex:
           return "^3[47][0-9]{5,}$"
        case .visa:
           return "^4[0-9]{6,}([0-9]{3})?$"
        case .master:
           return "^(5[1-5][0-9]{4}|677189)[0-9]{5,}$"
        case .dinners:
           return "^3(?:0[0-5]|[68][0-9])[0-9]{4,}$"
        case .discover:
           return "^6(?:011|5[0-9]{2})[0-9]{3,}$"
        case .jcb:
           return "^(?:2131|1800|35[0-9]{3})[0-9]{3,}$"
        case .uniionPay:
           return "^(62|88)[0-9]{5,}$"
        default:
           return ""
        }
    }
    
    static func cardType(brand: SQIPCardBrand) -> String {
        switch brand {
        case .visa:
            return CreditCardType.typeForServer(raw: CreditCardType.visa.rawValue)
        case .mastercard:
            return CreditCardType.typeForServer(raw: CreditCardType.master.rawValue)
        case .americanExpress:
            return CreditCardType.typeForServer(raw: CreditCardType.amex.rawValue)
        case .discover:
            return CreditCardType.typeForServer(raw: CreditCardType.discover.rawValue)
        case .discoverDiners:
            return CreditCardType.typeForServer(raw: CreditCardType.dinners.rawValue)
        case .JCB:
            return CreditCardType.typeForServer(raw: CreditCardType.jcb.rawValue)
        case .chinaUnionPay:
            return CreditCardType.typeForServer(raw: CreditCardType.uniionPay.rawValue)
        default:
            return CreditCardType.typeForServer(raw: CreditCardType.unknown.rawValue)
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
    
    var cardId: Int = 0
    
    var cardToken: String = ""
    var endingIn: String = ""
    
    var isDeleting: Bool = false
    
    var encryptedCardDetails: String = ""
    
    lazy var detailsRaw: CreditCardRawDetail? = {
        if let info = Utility.shared.decrypt(encryptedString: encryptedCardDetails),
            let object = Mapper<CreditCardRawDetail>().map(JSON: info) {
            return object
        }
        
        return nil
    }()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.typeRaw <- map["type"]
        
        self.cardToken <- map["token"]
        self.endingIn <- map["ending_in"]
        
        self.cardId <- map["id"]
        
        self.encryptedCardDetails <- map["card_details"]
    }
}

class CreditCardRawDetail: Mappable {
    
    
    var name: String = ""
    var number: String = ""
    
    var expiryMonth: String = ""
    var expiryYear: String = ""
    
    var cvc: String = ""
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.number <- map["card_number"]
        self.name <- map["name"]
        
        self.expiryMonth <- map["expiry_month"]
        self.expiryYear <- map["expiry_year"]
        
        self.cvc <- map["cvc"]
    }
}
