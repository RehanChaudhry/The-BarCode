//
//  Deal.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

enum OfferType: String {
    case standard = "Standard",
    fiveADay = "5 A Day",
    live = "Live",
    exclusive = "Exclusive",
    bannerAds = "Chalkboard",
    unknown = "unknown"
    
    func serverParamValue() -> String {
        switch self {
        case .standard:
            return "standard"
        case .fiveADay:
            return "f_a_day"
        case .live:
            return "live"
        case .exclusive:
            return "exclusive"
        case .bannerAds:
            return "banner_ads"
        case .unknown:
            return "unknown"
        }
    }
    
}

enum DealStatus: String {
    case notStarted = "notStarted", started = "started", expired = "expired"
}

class Deal: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    var offerTypeId = Value.Required<String>("offer_type_id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var subTitle =  Value.Required<String>("sub_title", initial: "")
    var image = Value.Required<String>("image", initial: "")
    var detail = Value.Required<String>("detail", initial: "")
    var startDateRaw =  Value.Required<String>("start_date", initial: "")
    var endDateRaw = Value.Required<String>("end_date", initial: "")
    var startTimeRaw = Value.Required<String>("start_time", initial: "")
    var endTimeRaw = Value.Required<String>("end_time", initial: "")
    var status = Value.Required<Bool>("status", initial: false)
    var isNotified = Value.Required<Bool>("is_notified", initial: false)
    var imageUrl = Value.Required<String>("image_url", initial: "")
    var statusText = Value.Required<String>("status_text", initial: "")
    var startDateTimeRaw = Value.Required<String>("start_date_time", initial: "")
    var endDateTimeRaw = Value.Required<String>("end_date_time", initial: "")
    var establishment = Relationship.ToOne<Bar>("establishment")
    var offer = Relationship.ToOne<Offer>("offer")
    var canShare = Value.Required<Bool>("can_share", initial: false)

    var sharedByName = Value.Optional<String>("shared_by_name")
    var sharedId = Value.Optional<String>("shared_id")
    
    var shouldShowDate = Value.Required<Bool>("should_show_date", initial: false)
    var hasTime = Value.Required<Bool>("should_show_time", initial: true)
    
    var isBookmarked = Value.Required<Bool>("is_bookmarked", initial: false)
    
    var isScheduled = Value.Required<Bool>("is_scheduled", initial: false)
    
    var isVoucher = Value.Required<Bool>("is_voucher", initial: false) 

    var voucherAmount = Value.Optional<Double>("amount")
    
    var userVoucherId = Value.Optional<String>("user_voucher_id")
    
    var startDate: Date {
        get {
            return Utility.shared.serverFormattedDate(date: self.startDateRaw.value)
        }
    }
    
    var endDate: Date {
        get {
            return Utility.shared.serverFormattedDate(date: self.endDateRaw.value)
        }
    }
    
    var startTime: Date {
        get {
            return Utility.shared.serverFormattedTime(date: self.startTimeRaw.value)
        }
    }
    
    var endTime: Date {
        get {
            let computedEndTime = Utility.shared.serverFormattedTime(date: self.endTimeRaw.value)
            //If endTime is previous than the start time then add 1 day
            if self.startTime.compare(computedEndTime) == .orderedDescending {
                return computedEndTime.addingTimeInterval(60.0 * 60.0 * 24.0)
            } else {
                return Utility.shared.serverFormattedTime(date: self.endTimeRaw.value)
            }
        }
    }
    
    var startDateTime: Date {
        get {
            return Utility.shared.serverFormattedDateTime(date: self.startDateTimeRaw.value)
        }
    }
    
    var endDateTime: Date {
        get {
            return Utility.shared.serverFormattedDateTime(date: self.endDateTimeRaw.value)
        }
    }
    
    var showLoader: Bool = false
    var showSharingLoader: Bool = false
    
    var savingBookmarkStatus: Bool = false {
        didSet {
            debugPrint("loading status changed")
        }
    }
    
    func getCurrentStatus() -> (status: DealStatus, statusReason: String) {
        let offerStatus = OfferStatus(startDateTime: self.startDateTime,
                                      endDateTime: self.endDateTime,
                                      startTime: self.startTime,
                                      endTime: self.endTime)
        return offerStatus.getCurrentStatus()
    }
    
    func getStartsInRemainingSeconds() -> Int {
        let offerStatus = OfferStatus(startDateTime: self.startDateTime,
                                      endDateTime: self.endDateTime,
                                      startTime: self.startTime,
                                      endTime: self.endTime)
        return offerStatus.getStartsInRemainingSeconds()
    }
    
    func getExpiresInRemainingSeconds() -> Int {
        let offerStatus = OfferStatus(startDateTime: self.startDateTime,
                                      endDateTime: self.endDateTime,
                                      startTime: self.startTime,
                                      endTime: self.endTime)
        return offerStatus.getExpiresInRemainingSeconds()
    }
}


extension Deal: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Deal.id)
    }
    
    var uniqueIDValue: String {
        get { return self.id.value }
        set { self.id.value = newValue }
    }
    
    static func uniqueID(from source: [String : Any], in transaction: BaseDataTransaction) throws -> String? {
        return "\(String(describing: source["id"]!))"
    }
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.id.value = "\(source["id"]!)"
        self.establishmentId.value = "\(source["establishment_id"]!)"
        self.offerTypeId.value = "\(source["offer_type_id"]!)"
        self.title.value = source["title"]! as! String
        self.subTitle.value = source["sub_title"]! as! String
        self.image.value = source["image"]! as! String
        self.detail.value = source["description"]! as! String
        
        self.isVoucher.value = source["is_voucher"] as! Bool

        if self.isVoucher.value {
            
            self.startDateRaw.value = source["start_date"]! as? String ?? self.getDefaultDateString()
            self.endDateRaw.value = source["end_date"]! as? String ?? self.getDefaultDateString()
            self.startTimeRaw.value = source["start_time"]! as? String ?? self.getDefaultTimeString()
            self.endTimeRaw.value = source["end_time"]! as? String ??  self.getDefaultTimeString()
            self.startDateTimeRaw.value = source["start_date_time"]! as? String ?? self.getDefaultDateTimeString()
            self.endDateTimeRaw.value = source["end_date_time"]! as? String ?? self.getDefaultDateTimeString()
            
            self.voucherAmount.value = source["amount"] as? Double
            
        } else {
            self.startDateRaw.value = source["start_date"]! as! String
            self.endDateRaw.value = source["end_date"]! as! String
            self.startTimeRaw.value = source["start_time"]! as! String
            self.endTimeRaw.value = source["end_time"]! as! String
            self.startDateTimeRaw.value = source["start_date_time"]! as! String
            self.endDateTimeRaw.value = source["end_date_time"]! as! String
        }
                
        self.status.value = source["status"]! as! Bool
        //self.isNotified.value = source["is_notified"]! as! Bool
        self.imageUrl.value = source["image_url"] as! String
        self.statusText.value = source["status_text"] as! String
        self.isBookmarked.value = source["is_user_favourite"] as? Bool ?? false
       
        if let isScheduled = source["is_scheduler"] as? Bool {
            self.isScheduled.value = isScheduled
        }
        
        if let canShare = source["can_share"] as? Bool {
            self.canShare.value = canShare
        }
        
        if let item = source["establishments"] as? [String : Any] {
            let importedObject = try! transaction.importUniqueObject(Into<Bar>(), source: item)
            
            if importedObject != nil {
                self.establishment.value = importedObject
            }
        }
        
        if let sharedByName = source["shared_by_name"] as? String {
            self.sharedByName.value = sharedByName
        }
        
        if let sharedId = source["shared_id"] {
            self.sharedId.value = "\(sharedId)"
        }
        
        self.shouldShowDate.value = source["is_date_show"] as? Bool ?? false
        self.hasTime.value = source["should_show_time"] as? Bool ?? true
        
        if let userVoucherId = source["user_voucher_id"] {
            self.userVoucherId.value = "\(userVoucherId)"
        }

    }
}


extension Deal {

    func getDefaultDateString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }

    func getDefaultTimeString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    func getDefaultDateTimeString() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
