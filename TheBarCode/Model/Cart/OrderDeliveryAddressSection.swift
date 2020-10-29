//
//  OrderDeliveryAddressSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 06/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderDeliveryAddress: NSObject {
    
    var address: Address?
    
    var isLoading: Bool = false
    
    var deliveryCondition: String?
    
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
