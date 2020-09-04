//
//  Address.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 07/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class Address: Mappable {
    
    var id: String = ""
    var label: String = ""
    var address: String = ""
    var additionalInfo: String = ""
    
    var latitude: CLLocationDegrees = 0.0
    var longitude: CLLocationDegrees = 0.0
    
    var city: String = ""
    
    var isDeleting: Bool = false
    
    var isSelected: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id = "\(map.JSON["id"]!)"
        
        self.label <- map["title"]
        
        self.address <- map["address"]
        
        self.city <- map["city"]
        
        self.additionalInfo <- map["optional_note"]
        
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
    }
}
