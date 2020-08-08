//
//  OrderDeliveryAddressSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 06/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderDeliveryAddress: NSObject {
    
    var label: String = ""
    var address: String = ""
    var city: String = ""
    var note: String = ""
    
    init(label: String, address: String, city: String, note: String) {
        self.label = label
        self.address = address
        self.city = city
        self.note = note
    }
    
}

class OrderDeliveryAddressSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .deliveryAddress
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderDeliveryAddress]

    init(items: [OrderDeliveryAddress]) {
        self.items = items
    }
}
