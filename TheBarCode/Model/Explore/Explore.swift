//
//  Explore.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import CoreLocation

enum ExploreMappingType: String {
    case bars = "bars", deals = "deals", liveOffers = "liveOffers"
}

class Explore: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var userId = Value.Required<String>("user_id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var detail = Value.Required<String>("detail", initial: "")
    var managerName = Value.Required<String>("refresh_token", initial: "")
    var contactNumber = Value.Required<String>("contact_number", initial: "")
    var contactEmail = Value.Required<String>("contact_email", initial: "")
    var address = Value.Required<String>("address", initial: "")
    var website = Value.Required<String>("website", initial: "")
    var latitude = Value.Required<CLLocationDegrees>("latitude", initial: 0.0)
    var longitude = Value.Required<CLLocationDegrees>("longitude", initial: 0.0)
    var status = Value.Required<String>("status", initial: "")
    var code = Value.Required<Int>("code", initial: 0)
    var businessTiming = Value.Required<String>("business_timing", initial: "")
    var closeTime = Value.Optional<String>("close_time")
    var openingTime = Value.Optional<String>("opening_time")
    var instagramProfileUrl = Value.Optional<String>("instagram_profile_url")
    var twitterProfileUrl = Value.Optional<String>("twitter_profile_url")
    var googlePageUrl = Value.Optional<String>("google_page_url")
    var facebookPageUrl = Value.Optional<String>("facebook_page_url")
    var formattedUpdatedAt = Value.Optional<String>("formatted_updated_at")
    var distance = Value.Required<Double>("distance", initial: 0.0)
    var canRedeemOffer = Value.Required<Bool>("is_offer_redeemed", initial: false)
    var deals = Value.Required<Int>("deals", initial: 0)
    var liveOffers = Value.Required<Int>("live_offers", initial: 0)
    var isUserFavourite = Value.Required<Bool>("is_user_favourite", initial: false)
    var credit = Value.Required<Int>("credit", initial: 0)
    
    var images = Relationship.ToManyOrdered<ImageItem>("images", inverse: { $0.explore })
    
    var lastReloadTime = Value.Required<String>("last_reload_time", initial: "") //TODO dateObject
    
}


extension Explore: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Explore.id)
    }
    
    var uniqueIDValue: String {
        get { return self.id.value }
        set { self.id.value = newValue }
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
        
        self.userId.value = "\(source["user_id"]!)"
        self.title.value = source["title"] as! String
        self.detail.value = source["description"] as! String
        self.managerName.value = source["manager_name"] as! String
        self.contactNumber.value = source["contact_number"] as! String
        self.contactEmail.value = source["contact_email"] as! String
        self.address.value = source["address"] as! String
        self.website.value = source["website"] as! String
        
        self.latitude.value = CLLocationDegrees("\(source["latitude"] ?? 0.0)")!
        self.longitude.value = CLLocationDegrees("\(source["longitude"] ?? 0.0)")!
        
        self.status.value = source["status"] as! String
        self.code.value = source["code"] as! Int
        self.businessTiming.value = source["business_timing"] as! String
        self.closeTime.value = source["close_time"] as? String
        self.openingTime.value = source["opening_time"] as? String
        self.instagramProfileUrl.value = source["instagram_profile_url"] as? String
        self.twitterProfileUrl.value = source["twitter_profile_url"] as? String
        self.googlePageUrl.value = source["google_page_url"] as? String
        self.facebookPageUrl.value = source["facebook_page_url"] as? String
        self.formattedUpdatedAt.value = source["formatted_updated_at"] as? String
        
        self.distance.value = Double("\(source["distance"] ?? 0.0)")!
        
        self.canRedeemOffer.value = source["can_redeem_offer"] as! Bool
        
        self.isUserFavourite.value = source["is_user_favourite"] as! Bool
        self.credit.value = source["credit"] as! Int

        if let items = source["images"] as? [[String : Any]] {
            let importedObjects = try! transaction.importObjects(Into<ImageItem>(), sourceArray: items)
            
            if !importedObjects.isEmpty {
                self.images.value = importedObjects
            }
        }
        
        if let mappingTypeRaw = (source["mapping_type"] as? String), let mappingType = ExploreMappingType(rawValue: mappingTypeRaw) {
            if mappingType == .bars {
                
            } else if mappingType == .deals {
                self.deals.value = Int("\(source["deals"]!)")!
            } else if mappingType == .liveOffers {
                self.liveOffers.value = Int("\(source["live_offers"]!)")!
            }
        }
        
        //TODO: handle array and object
//        self.images.value = source["images"] as! String
//        self.lastReloadTime.value = source["last_reload_time"] as! String
    }
}


