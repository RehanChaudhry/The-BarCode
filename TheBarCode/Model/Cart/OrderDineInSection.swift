//
//  OrderDineInSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderDineInSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .dineIn
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderRadioButton]

    init(items: [OrderRadioButton]) {
        self.items = items
    }
}
