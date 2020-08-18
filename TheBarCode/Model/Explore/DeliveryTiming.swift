//
//  DeliveryTiming.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

enum DeliveryStatus: String {
    case available = "on", unavailable = "off"
}

class DeliveryTiming: CoreStoreObject, ImportableObject {
    
    var fromTime = Value.Optional<Date>("opening_time")
    var toTime = Value.Optional<Date>("closing_time")
    
    var fromTimeRaw = Value.Required<String>("opening_time_raw", initial: "")
    var toTimeRaw = Value.Required<String>("closing_time_raw", initial: "")
    
    var day = Value.Required<String>("day", initial: "")
    
    var statusRaw = Value.Required<String>("day_status", initial: "")
    
    var dayStatus: DeliveryStatus {
        get {
            return DeliveryStatus(rawValue: self.statusRaw.value) ?? .unavailable
        }
    }
    
    var explore = Relationship.ToOne<Explore>("explore")
    
    typealias ImportSource = [String: Any]
    
    func didInsert(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        self.updateInCoreStore(source: source, transaction: transaction)
    }
    
    func update(from source: [String : Any], in transaction: BaseDataTransaction) throws {
        self.updateInCoreStore(source: source, transaction: transaction)
    }
    
    func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
        
        self.statusRaw.value = source["status"] as? String ?? ""
        self.day.value = source["day"] as? String ?? ""
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateformatter.timeZone = serverTimeZone
        
        if let openingDateTimeInfo = source["from_modify"] as? [String : Any], let fromDateTime = openingDateTimeInfo["date"] as? String {
            self.fromTimeRaw.value = fromDateTime
            self.fromTime.value = dateformatter.date(from: fromDateTime)
        }
        
        if let closingDateTimeInfo = source["to_modify"] as? [String : Any], let toDateTime = closingDateTimeInfo["date"] as? String {
            self.toTimeRaw.value = toDateTime
            self.toTime.value = dateformatter.date(from: toDateTime)
        }
    }
    
}

