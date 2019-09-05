//
//  MapBasicBar.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class MapBasicBar: NSObject, Mappable {
    
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    var barId: String!
    
    var standardOfferType: StandardOfferType {
        get {
            if let standardOfferTypeRaw = self.standardOfferTypeRaw {
                return StandardOfferType(rawValue: standardOfferTypeRaw) ?? .other
            } else {
                return .silver
            }
        }
    }
    
    var standardOfferTypeRaw: String?

    var isOpen: Bool = true
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.latitude = CLLocationDegrees("\(map.JSON["latitude"]!)")!
        self.longitude = CLLocationDegrees("\(map.JSON["longitude"]!)")!
        
        self.barId = "\(map.JSON["id"]!)"
        
        if let activeStandardOffer = map.JSON["standard_offer"] as? [String : Any] {
            self.standardOfferTypeRaw = "\(activeStandardOffer["tier_id"]!)"
        }
        
        if let timings = map.JSON["establishment_timings"] as? [String : Any],
            let dayStatusRaw = timings["status"] as? String,
            let dayStatus = EstablishmentOpenStatus(rawValue: dayStatusRaw),
            let isOpen = timings["is_bar_open"] as? Bool {
            
            if dayStatus == .opened {
                if isOpen {
                    self.isOpen = true
                } else {
                    self.isOpen = false
                }
            } else {
                self.isOpen = false
            }
            
        } else {
            self.isOpen = false
        }
    }
}

//MARK: GMUClusterItem
extension MapBasicBar: GMUClusterItem {
    var position: CLLocationCoordinate2D {
        get {
            let coordinates = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            if CLLocationCoordinate2DIsValid(coordinates) {
                return coordinates
            } else {
                return kCLLocationCoordinate2DInvalid
            }
        }
    }
}
