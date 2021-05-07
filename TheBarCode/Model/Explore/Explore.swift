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

enum BarType: String {
    case standardBar = "standard",
    exclusiveBar = "exclusive"
}

enum MenuType: String {
    case barCode = "barcode",
    deliverect = "deliverect",
    squareup = "squareup",
    other = "other"
}

class Explore: CoreStoreObject , ImportableUniqueObject {
    
    var id = Value.Required<String>("id", initial: "")
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
    var chalkboardDeals = Value.Required<Int>("chalkboard_deals", initial: 0)
    var exclusiveDeals = Value.Required<Int>("exclusive_deals", initial: 0)
    
    var liveOffers = Value.Required<Int>("live_offers", initial: 0)
    var isUserFavourite = Value.Required<Bool>("is_user_favourite", initial: false)
    var credit = Value.Required<Int>("credit", initial: 0)
    
    //Determine weather establishment is opt in for unlimited redemption
    var isOfferingUnlimitedRedemption = Value.Required<Bool>("is_offering_unlimited_redemption", initial: false)
    var canDoUnlimitedRedemption = Value.Required<Bool>("can_do_unlimited_redemption", initial: false)
    
    var videoUrlString = Value.Optional<String>("video_url_string")
    
    var images = Relationship.ToManyOrdered<ImageItem>("images", inverse: { $0.explore })
    
    var lastReloadTime = Value.Required<String>("last_reload_time", initial: "") //TODO dateObject
    
    var timings = Relationship.ToOne<EstablishmentTiming>("establishment_timings", inverse: { $0.explore })
    
    var weeklySchedule = Relationship.ToManyOrdered<ExploreSchedule>("weekly_schedule", inverse: {$0.explore})
    var deliverySchedule = Relationship.ToManyOrdered<DeliveryTiming>("delivery_schedule", inverse: { $0.explore })
    
    var isVoucherOn = Value.Required<Bool>("is_voucher_on", initial: false)
    var isInAppPaymentOn = Value.Required<Bool>("is_payment_app", initial: false)
    
    var isDeliveryAvailable = Value.Required<Bool>("is_deliver", initial: false)
    var isCurrentlyDelivering = Value.Required<Bool>("is_delivery_disable", initial: false)
    var hasFixedDeliveryCharges = Value.Required<Bool>("is_global_delivery", initial: false)
    var hasFullDayDelivery = Value.Required<Bool>("is_full_day_delivery", initial: false)
    
    var isReservationAllowed = Value.Required<Bool>("is_reservation", initial: false)
    var reservationUrl = Value.Required<String>("reservation_url", initial: "")
    
    var deliveryCondition = Value.Required<String>("delivery_condition", initial: "")
    var deliveryRadius = Value.Required<Double>("delivery_distance", initial: 0.0)
    
    var barTypeRaw = Value.Required<String>("bar_type_raw", initial: "")
        
    var country = Value.Required<String>("country", initial: "United Kingdom (UK)")
    var currencySymbol = Value.Required<String>("currency_symbol", initial: "£")
    var currencyCode = Value.Required<String>("currency_code", initial: "GBP")
    
    var barType: BarType {
        get {
            return BarType(rawValue: self.barTypeRaw.value) ?? .standardBar
        }
    }
    
    var menuTypeRaw = Value.Required<String>("menu_type_raw", initial: MenuType.barCode.rawValue)
    
    var menuType: MenuType {
        get {
            return MenuType(rawValue: self.menuTypeRaw.value) ?? .other
        }
    }
    
    var currentlyBarIsOpened: Bool {
        get {
            if let timings = self.timings.value {
                if timings.dayStatus == .opened {
                    return timings.isOpen.value
                }
            }
            
            return false
        }
    }
    
    var currentlyUnlimitedRedemptionAllowed: Bool {
        get {
            if let timings = self.timings.value,
                self.isOfferingUnlimitedRedemption.value,
                timings.dayStatus == .opened,
                timings.isOfferingUnlimitedRedemption.value {
                return true
            }
            
            return false
        }
    }
//}

    var currentImageIndex: Int = 0
    
    var timingExpanded: Bool = false
    var deliveryExpanded: Bool = false

//extension Explore: ImportableUniqueObject {
    
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
        
        self.id.value = "\(source["id"]!)"

        self.title.value = source["title"] as! String
        self.detail.value = source["description"] as! String
        self.managerName.value = source["manager_name"] as! String
        self.contactNumber.value = source["contact_number"] as? String ?? ""
        self.contactEmail.value = source["contact_email"] as! String
        self.address.value = source["address"] as! String
        
        if let website = source["website"] as? String {
            self.website.value = website
        } else {
            self.website.value = ""
        }
        
        self.latitude.value = CLLocationDegrees("\(source["latitude"] ?? 0.0)")!
        self.longitude.value = CLLocationDegrees("\(source["longitude"] ?? 0.0)")!
        
        self.status.value = source["status"] as! String

        self.businessTiming.value = source["business_timing"] as? String ?? ""
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
        self.credit.value = Int("\(source["credit"]!)")!

        if let items = source["images"] as? [[String : Any]] {
            let importedObjects = try! transaction.importObjects(Into<ImageItem>(), sourceArray: items)
            
            if !importedObjects.isEmpty {
                self.images.value = importedObjects
            }
        }
        
        if let mappingTypeRaw = (source["mapping_type"] as? String), let mappingType = ExploreMappingType(rawValue: mappingTypeRaw) {
            if mappingType == .bars {
                
            } else if mappingType == .deals {
                
                if let _ = source["deals_chalkboard"] {
                    self.chalkboardDeals.value = Int("\(source["deals_chalkboard"]!)") ?? 0
                }
                
                if let _ = source["deals_exclusive"] {
                    self.exclusiveDeals.value = Int("\(source["deals_exclusive"]!)") ?? 0
                }
                
                self.deals.value = Int("\(source["deals"]!)")!
                
            } else if mappingType == .liveOffers {
                self.liveOffers.value = Int("\(source["live_offers"]!)")!
            }
        }
        
        if let timingsSource = source["establishment_timings"] as? [String : Any] {
            let importTimings = try! transaction.importObject(Into<EstablishmentTiming>(), source: timingsSource)
            self.timings.value = importTimings
            
            let bars = try! transaction.fetchAll(From<Explore>().where(\.id == self.id.value))
            for bar in bars {
                let edit = transaction.edit(bar)
                let timings = edit?.timings.value
                timings?.isOpen.value = importTimings!.isOpen.value
                timings?.openingTime.value = importTimings!.openingTime.value
                timings?.closingTime.value = importTimings!.closingTime.value
                timings?.day.value = importTimings!.day.value
                timings?.dayStatusRaw.value = importTimings!.dayStatusRaw.value
            }
            
        }
        
        if let scheduleSource = source["week_establishment_timings"] as? [[String : Any]] {
            let importSchedule = try! transaction.importObjects(Into<ExploreSchedule>(), sourceArray: scheduleSource)
            self.weeklySchedule.value = importSchedule
            
            let bars = try! transaction.fetchAll(From<Explore>().where(\.id == self.id.value))
            for bar in bars {
                let edit = transaction.edit(bar)
                let timings = edit?.weeklySchedule.value ?? []
                
                for time in timings {
                    let day = self.weeklySchedule.value.first(where: {$0.day.value == time.day.value})
                    
                    time.closingTime.value = day?.closingTime.value
                    time.openingTime.value = day?.openingTime.value
                    time.day.value = day?.day.value ?? ""
                    time.dayStatusRaw.value = day?.dayStatusRaw.value ?? ""
                }
            }
        }
        
        if let scheduleSource = source["delivery_timings"] as? [[String : Any]] {
            let importSchedule = try! transaction.importObjects(Into<DeliveryTiming>(), sourceArray: scheduleSource)
            self.deliverySchedule.value = importSchedule
            
            let bars = try! transaction.fetchAll(From<Explore>().where(\.id == self.id.value))
            for bar in bars {
                let edit = transaction.edit(bar)
                let timings = edit?.deliverySchedule.value ?? []
                
                for time in timings {
                    let day = self.deliverySchedule.value.first(where: {$0.day.value == time.day.value})
                    
                    time.toTime.value = day?.toTime.value
                    time.fromTime.value = day?.fromTime.value
                    time.day.value = day?.day.value ?? ""
                    time.statusRaw.value = day?.statusRaw.value ?? ""
                }
            }
        }
        
        if let videoDict = source["video"] as? [String : Any], let videoUrlString = videoDict["url"] as? String, videoUrlString.count > 0 {
            self.videoUrlString.value = videoUrlString
        } else {
            self.videoUrlString.value = nil
        }
        
        if let unlimitedRedemptionAllowed = source["is_unlimited_redemption"] as? Bool {
            self.isOfferingUnlimitedRedemption.value = unlimitedRedemptionAllowed
        }
        
        if let canDoUnlimitedRedemption = source["can_unlimited_redeem"] as? Bool {
            self.canDoUnlimitedRedemption.value = canDoUnlimitedRedemption
        }
        
        if let voucherOn = source["is_voucher_on"] as? Bool {
            self.isVoucherOn.value = voucherOn
        }
        
        if let isInAppPaymentOn = source["is_payment_app"] as? Bool {
            self.isInAppPaymentOn.value = isInAppPaymentOn
        }
        
        if let isDeliveryAvailable = source["is_deliver"] as? Bool {
            self.isDeliveryAvailable.value = isDeliveryAvailable
        }
        
        if let isCurrentlyDelivering = source["is_delivery_disable"] as? Bool {
            self.isCurrentlyDelivering.value = isCurrentlyDelivering
        }
        
        if let hasFullDayDelivery = source["is_full_day_delivery"] as? Bool {
            self.hasFullDayDelivery.value = hasFullDayDelivery
        }
        
        if let hasFixedDeliveryCharges = source["is_global_delivery"] as? Bool {
            self.hasFixedDeliveryCharges.value = hasFixedDeliveryCharges
        }
        
        if let _ = source["delivery_distance"] {
            self.deliveryRadius.value = Double("\(source["delivery_distance"]!)") ?? 0.0
        }
        
        if let deliveryCondition = source["delivery_condition"] as? String {
            self.deliveryCondition.value = deliveryCondition
        }
        
        if let type = source["type"] as? String {
            self.barTypeRaw.value = type
        }
        
        if let type = source["epos_name"] as? String {
            self.menuTypeRaw.value = type
        }
        
        self.isReservationAllowed.value = source["is_reservation"] as? Bool ?? false
        self.reservationUrl.value = source["reservation_url"] as? String ?? ""
        
        if let region = source["region"] as? [String : Any],
           let country = region["country"] as? String,
           let currencyCode = region["currency_code"] as? String,
           let currencySymbol = region["currency_symbol"] as? String {
            self.country.value = country
            self.currencyCode.value = currencyCode
            self.currencySymbol.value = currencySymbol
        }
    }
}


