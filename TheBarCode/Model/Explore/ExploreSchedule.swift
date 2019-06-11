//
//  ExploreSchedule.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/05/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class ExploreSchedule: CoreStoreObject, ImportableObject {
    
    var openingTime = Value.Optional<Date>("opening_time")
    var closingTime = Value.Optional<Date>("closing_time")
    
    var day = Value.Required<String>("day", initial: "")
    
    var dayStatusRaw = Value.Required<String>("day_status", initial: "")
    
    var dayStatus: EstablishmentOpenStatus {
        get {
            return EstablishmentOpenStatus(rawValue: self.dayStatusRaw.value) ?? EstablishmentOpenStatus.closed
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
        
        self.day.value = source["day"] as? String ?? ""
        self.dayStatusRaw.value = source["status"] as? String ?? ""
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        dateformatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let openingDateTimeInfo = source["opening_time_modify"] as? [String : Any], let openingDateTime = openingDateTimeInfo["date"] as? String {
            self.openingTime.value = dateformatter.date(from: openingDateTime)
        }
        
        if let closingDateTimeInfo = source["closed_time_modify"] as? [String : Any], let closingDateTime = closingDateTimeInfo["date"] as? String {
            self.closingTime.value = dateformatter.date(from: closingDateTime)
        }
    }
}
