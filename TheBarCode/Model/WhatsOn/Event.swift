//
//  Event.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import CoreLocation

enum EventStatus: String {
    case notStarted = "notStarted", started = "started", expired = "expired"
}

class Event: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    var establishmentName = Value.Required<String>("establishment_name", initial: "")
    
    var image = Value.Required<String>("image", initial: "")
    var locationName = Value.Required<String>("location", initial: "")
    
    var lat = Value.Required<CLLocationDegrees>("lat", initial: 0.0)
    var lng = Value.Required<CLLocationDegrees>("lng", initial: 0.0)
    
    var name = Value.Required<String>("name", initial: "")
    var detail = Value.Required<String>("desc", initial: "")
    
    var date = Value.Optional<Date>("date")
    
    var sharedId = Value.Optional<String>("shared_id")
    var sharedByName = Value.Optional<String>("shared_by_name")
    
    var formattedDateString: String {
        get {
            if let date = self.date.value {
                var dateString = ""
                
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "MMM dd, yyyy"
                
                dateString.append(dateformatter.string(from: date))
                
                dateString.append(" at ")
                
                dateformatter.dateFormat = "HH:mm:ss"
                
                dateString.append(dateformatter.string(from: date))
                
                return dateString
                
            } else {
                return ""
            }
        }
    }
    
    var bar = Relationship.ToOne<Bar>("bar")
    
    var startDateRaw =  Value.Required<String>("start_date", initial: "")
    var endDateRaw = Value.Required<String>("end_date", initial: "")
    var startTimeRaw = Value.Required<String>("start_time", initial: "")
    var endTimeRaw = Value.Required<String>("end_time", initial: "")
    var startDateTimeRaw = Value.Required<String>("start_date_time", initial: "")
    var endDateTimeRaw = Value.Required<String>("end_date_time", initial: "")
    
    var isBookmarked = Value.Required<Bool>("is_bookmarked", initial: false)
    
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
            return Utility.shared.serverFormattedTime(date: self.endTimeRaw.value)
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
    
    var externalCTAs = Relationship.ToManyOrdered<EventExternalCTA>("external_ctas", inverse: { $0.event })
    
    var shouldShowDate = Value.Required<Bool>("should_show_date", initial: false)
    var shouldShowTime = Value.Required<Bool>("should_show_time", initial: false)
}

extension Event: ImportableUniqueObject {
    
    typealias ImportSource = [String: Any]
    
    class var uniqueIDKeyPath: String {
        return String(keyPath: \Event.id)
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
        self.establishmentId.value = "\(source["establishment_id"]!)"
        
        self.image.value = source["image"] as? String ?? ""
        self.locationName.value = source["location"] as? String ?? ""
        
        if let _ = source["latitude"] {
            self.lat.value = CLLocationDegrees("\(source["latitude"]!)") ?? 0.0
        } else {
            self.lat.value = 0.0
        }
        
        if let _ = source["longitude"] {
            self.lng.value = CLLocationDegrees("\(source["longitude"]!)") ?? 0.0
        } else {
            self.lng.value = 0.0
        }
        
        self.name.value = source["name"] as? String ?? ""
        self.detail.value = source["description"] as? String ?? ""
        
        if let dateString = source["date"] as? String {
            let date = Utility.shared.serverFormattedDateTime(date: dateString)
            self.date.value = date
        } else {
            self.date.value = nil
        }
        
        if let barSource = source["establishment"] as? [String : Any] {
            var mutableBarSource = barSource
            mutableBarSource["mapping_type"] = ExploreMappingType.bars.rawValue
            let bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarSource)
            self.bar.value = bar!
        }
        
        self.isBookmarked.value = source["is_user_favourite"] as? Bool ?? false
        
        self.startDateRaw.value = source["start_date"]! as! String
        self.endDateRaw.value = source["end_date"]! as! String
        self.startTimeRaw.value = source["start_time"]! as! String
        self.endTimeRaw.value = source["end_time"]! as! String
        
        self.startDateTimeRaw.value = self.startDateRaw.value + " " + self.startTimeRaw.value
        self.endDateTimeRaw.value = self.endDateRaw.value + " " + self.endTimeRaw.value
        
        if let externalLinks = source["links"] as? [[String : Any]] {
            self.externalCTAs.value = try! transaction.importObjects(Into<EventExternalCTA>(), sourceArray: externalLinks)
        } else {
            self.externalCTAs.value = []
        }
        
        self.shouldShowDate.value = source["is_date_show"] as? Bool ?? false
        self.shouldShowTime.value = source["is_time_selected"] as? Bool ?? false
        
        if let _ = source["shared_id"] {
            self.sharedId.value = "\(source["shared_id"]!)"
        }
        
        if let shareByName = source["shared_by_name"] as? String {
            self.sharedByName.value = shareByName
        }
    }
}
