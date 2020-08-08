//
//  OrderDineInFieldSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderDineInField: NSObject {
    var text: String = ""
}

class OrderDineInFieldSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .tableNo
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderDineInField]

    init(items: [OrderDineInField]) {
        self.items = items
    }
}
