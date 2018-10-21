//
//  RedeemInfo.swift
//  TheBarCode
//
//  Created by Aasna Islam on 19/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import Foundation
import ObjectMapper

class RedeemInfo: Mappable {
    
    var isFirstRedeem: Bool = false
    var redeemDatetime: String!
    var currentServerDatetime: String!
    var remainingSeconds : Int!
    
    required convenience init?( map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        isFirstRedeem <- map["is_first_redeem"]

        //TODO
        let redeemdateObj = map["redeem_datetime"].currentValue as! [String:Any]
        let redeemTime = redeemdateObj["date"]
        redeemDatetime = redeemTime! as? String
        
        let serverTimeObj = map["current_server_datetime"].currentValue as! [String:Any]
        let serverTime = serverTimeObj["date"]
        currentServerDatetime = serverTime! as? String
        
        remainingSeconds <- map["remaining_seconds"]
    }
    
    func canShowTimer() -> Bool {
        return (self.redeemDatetime != "" && self.currentServerDatetime != "")
    }
    
}
