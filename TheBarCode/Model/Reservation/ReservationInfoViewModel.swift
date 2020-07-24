//
//  InfoModelView.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//


import Foundation

class ReservationInfo: NSObject {
    
    var title: String = ""
    var value: String = ""
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
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
