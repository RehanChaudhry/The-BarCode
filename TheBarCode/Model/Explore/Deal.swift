//
//  Deal.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class Deal: CoreStoreObject {
    
    var id = Value.Required<String>("id", initial: "")
    var establishmentId = Value.Required<String>("establishment_id", initial: "")
    var offerTypeId = Value.Required<String>("offer_type_id", initial: "")
    var title = Value.Required<String>("title", initial: "")
    var subTitle =  Value.Required<String>("sub_title", initial: "")
    var image = Value.Required<String>("image", initial: "")
    var detail = Value.Required<String>("detail", initial: "")
    var startDate =  Value.Required<String>("start_date", initial: "")
    var endDate = Value.Required<String>("end_date", initial: "")
    var startTime = Value.Required<String>("start_time", initial: "")
    var endTime = Value.Required<String>("end_time", initial: "")
    var status = Value.Required<Bool>("status", initial: false)
    var isNotified = Value.Required<Bool>("is_notified", initial: false)
    var imageUrl = Value.Optional<String>("image_url")
    var statusText = Value.Required<String>("status_text", initial: "")
    var starDateTime = Value.Required<String>("start_date_time", initial: "")
    var endDateTime = Value.Required<String>("end_date_time", initial: "")
    var establishment = Relationship.ToOne<Bar>("establishment")
    var offer = Relationship.ToOne<Offer>("offer")
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
        
        self.id.value = "\(String(describing: source["id"]!))"
        self.establishmentId.value = "\(String(describing: source["establishment_id"]!))"
        self.offerTypeId.value = "\(String(describing: source["offer_type_id"]!))"
        self.title.value = source["title"]! as! String
        self.subTitle.value = source["sub_title"]! as! String
        self.image.value = source["image"]! as! String
        self.detail.value = source["description"]! as! String
        self.startDate.value = source["start_date"]! as! String
        self.endDate.value = source["end_date"]! as! String
        self.startTime.value = source["start_time"]! as! String
        self.endTime.value = source["end_time"]! as! String
        self.status.value = source["status"]! as! Bool
        self.isNotified.value = source["is_notified"]! as! Bool
        self.imageUrl.value = source["image_url"] as? String
        self.starDateTime.value = source["start_date_time"]! as! String
        self.endDateTime.value = source["end_date_time"]! as! String
        
        
        if let item = source["establishments"] as? [String : Any] {
            let importedObject = try! transaction.importUniqueObject(Into<Bar>(), source: item)
            
            if importedObject != nil {
                self.establishment.value = importedObject
            }
        }
        
    }
}
