//
//  Notification.swift
//  TheBarCode
//
//  Created by Macbook on 12/05/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper

class NotificationItem: Mappable {
    
    var title: String = ""
    var offerTitle: String = ""
    var notificationTypeRaw: String = ""
    var establishmentId: String = ""
    var message: String = ""
    
    var createdAtDateRaw: String = ""
    var createdAtTimezoneType : Int = 0
    var createdAtTimezone: String = ""
    
    var notificationType: NotificationType? {
        get{
            return NotificationType(rawValue: notificationTypeRaw)
        }
    }

    var createdAtDate: Date {
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            dateFormatter.timeZone = serverTimeZone
            return dateFormatter.date(from: self.createdAtDateRaw)!
        }
    }
    
    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        
        self.title <- map["title"]
        self.offerTitle <- map["offer_title"]
        self.notificationTypeRaw <- map["type"]
        if let establishmentId = map.JSON["establishment_id"] {
             self.establishmentId = "\(establishmentId)"
        }
        self.message <- map["message"]
        self.establishmentId <- map["establishment_id"]
        self.createdAtDateRaw <- map["created_at.date"]
        self.createdAtTimezoneType <- map["created_at.timezone_type"]
        self.createdAtTimezone <- map["created_at.timezone"]
    }
    
}
