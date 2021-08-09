//
//  OrderDetailPhoneNumber.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 09/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import Foundation

class OrderDetailPhoneNumber : NSObject {
    var headingPhoneNumber: String = ""
    var titlePhoneNumber: String = ""
    
    init(headingPhoneNumber: String, titlePhoneNumber: String) {
        self.headingPhoneNumber = headingPhoneNumber
        self.titlePhoneNumber = titlePhoneNumber
    }
}

class OrderDetailPhoneNumberSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .phoneNumber
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderDetailPhoneNumber]

    init(items: [OrderDetailPhoneNumber]) {
        self.items = items
    }
}
