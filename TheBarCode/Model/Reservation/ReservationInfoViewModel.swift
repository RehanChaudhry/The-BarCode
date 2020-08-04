//
//  InfoModelView.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//


import Foundation

enum ReservationInfoType: String {
    case general = "general", card = "card"
}

class ReservationInfo: NSObject {
    
    var title: String = ""
    var value: String = ""
    
    var type: ReservationInfoType = .general
    
    init(title: String, value: String, type: ReservationInfoType = .general) {
        self.title = title
        self.value = value
        
        self.type = type
    }
}

class ReservationInfoViewModel: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .reservationDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [ReservationInfo]
    
    init(items: [ReservationInfo]) {
        self.items = items
    }
    
}

class ReservationStatusViewModel: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .reservationStatus
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [ReservationInfo]
    
    init(items: [ReservationInfo]) {
        self.items = items
    }
    
}
