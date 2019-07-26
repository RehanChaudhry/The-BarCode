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

class Event: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    
    var image = Value.Required<String>("image", initial: "")
    var locationName = Value.Required<String>("location", initial: "")
    
    var lat = Value.Required<CLLocationDegrees>("lat", initial: 0.0)
    var lng = Value.Required<CLLocationDegrees>("lng", initial: 0.0)
    
    var name = Value.Required<String>("name", initial: "")
    var detail = Value.Required<String>("desc", initial: "")
    
    var date = Value.Optional<Date>("date")
    
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
        
    }
}
