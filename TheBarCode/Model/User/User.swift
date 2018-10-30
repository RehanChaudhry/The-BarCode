//
//  User.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

enum UserStatus: String {
    case active = "active",
    pending = "pending",
    blocked = "blocked",
    other = "other"
}

class User: CoreStoreObject {
    
    var userId = Value.Required<String>("user_id", initial: "")
    
    var fullName = Value.Required<String>("fullname", initial: "")
    var email = Value.Required<String>("email_id", initial: "")
    var accessToken = Value.Required<String>("access_token", initial: "")
    var refreshToken = Value.Required<String>("refresh_token", initial: "")
    var dobString = Value.Required<String>("date_of_birth", initial: "")
    var genderString = Value.Required<String>("gender", initial: "")
    var ownReferralCode = Value.Required<String>("own_referral_code", initial: "")
    var statusRaw = Value.Required<String>("status", initial: "")
    
    var liveOfferNotificationEnabled = Value.Required<Bool>("live_offer_notif_enabled", initial: true)
    var fiveADayNotificationEnabled = Value.Required<Bool>("five_a_day_notif_enabled", initial: true)
    
    var isCategorySelected = Value.Required<Bool>("is_category_selected", initial: false)
    var isLocationUpdated = Value.Required<Bool>("is_location_update", initial: false)
    
    var profileImage = Value.Optional<String>("profile_image")
    var socialAccountId = Value.Optional<String>("social_account_id")
    var referralCode = Value.Optional<String>("referral_code")
    
    var creditsRaw = Value.Optional<String>("credits_raw")
    
    var gender: Gender {
        get {
            return Gender(rawValue: self.genderString.value.lowercased()) ?? .other
        }
    }
    
    var credit: Int {
        get {
            return Int(creditsRaw.value!) ?? 0
        }
    }
    
    var status: UserStatus {
        get {
            if let userStatus = UserStatus(rawValue: self.statusRaw.value) {
                return userStatus
            } else {
                return UserStatus.other
            }
        }
    }
    
    
}


extension User: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \User.userId)
    }
    
    var uniqueIDValue: String {
        get { return self.userId.value }
        set { self.userId.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return "\(source["id"]!)"
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.fullName.value = source["full_name"] as! String
        self.email.value = source["email"] as! String
        self.dobString.value = source["date_of_birth"] as! String
        self.genderString.value = source["gender"] as! String
        self.accessToken.value = source["access_token"] as! String
//        self.refreshToken.value = source["refresh_token"] as! String
        self.ownReferralCode.value = source["own_referral_code"] as! String
        self.statusRaw.value = source["status"] as! String
        self.creditsRaw.value = "\(source["credit"]!)"
        
        self.liveOfferNotificationEnabled.value = source["is_live_offer_notify"] as! Bool
        self.fiveADayNotificationEnabled.value = source["is_5_day_notify"] as! Bool
        self.isCategorySelected.value = source["is_interest_selected"] as! Bool
        
        self.profileImage.value = source["profile_image"] as? String
        
        
        if let isLocationUpdated = source["is_location_updated"] as? Bool {
            self.isLocationUpdated.value = isLocationUpdated
        } else {
            self.isLocationUpdated.value = false
        }
        
        if let socialAccountId = source["social_account_id"] as? String {
            self.socialAccountId.value = socialAccountId
        } else if let socialAccountId = source["social_account_id"] as? Int {
            self.socialAccountId.value = "\(socialAccountId)"
        }
        
        if let referralCode = source["referral_code"] as? String, referralCode.count > 0 {
            self.referralCode.value = referralCode
        }
        
        
        
    }
}
