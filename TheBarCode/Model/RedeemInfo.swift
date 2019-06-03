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
    var remainingSeconds : Int!
    var canReload: Bool = false
    
    required convenience init?( map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        isFirstRedeem <- map["is_first_redeem"]
        remainingSeconds <- map["remaining_seconds"]
        
        debugPrint("remaining seconds for reload: \(String(describing: remainingSeconds))")
    }
    
    func canShowTimer() -> Bool {
        return (self.remainingSeconds > 0)
    }
    
}

/*
class ReedeemInfoManager {
    
    static let shared = ReedeemInfoManager()
    var redeemInfo: RedeemInfo?
    var canReload: Bool = true
    var isTimerRunning: Bool = false
    
    init(){}
    
    func saveRedeemInfo(redeemDic: [String: Any]) {
        let userDefaults = UserDefaults.standard        
        userDefaults.removeObject(forKey: "redeemInfo")
        userDefaults.set(redeemDic, forKey: "redeemInfo")
        self.redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemDic)!
        debugPrint("redeemInfo saved with remaining seconds == \(String(describing: self.redeemInfo?.remainingSeconds))")
    }
    
    func removeRedeemInfo() {
        self.redeemInfo = nil
        UserDefaults.standard.removeObject(forKey: "redeemInfo")
        debugPrint("redeemInfo removed")

    }
    
    func updateRedeemInfo() -> Int {
        if let remainingSeconds = self.redeemInfo!.remainingSeconds {
            self.redeemInfo!.remainingSeconds = remainingSeconds - 1
            return self.redeemInfo!.remainingSeconds
        }
        return -1
    }
}
*/
