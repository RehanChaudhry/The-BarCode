//
//  OrderSplitBillTypeSection.swift
//  TheBarCode
//
//  Created by Mac OS X on 09/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderSplitBillTypeSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderRadioButton]

    init(items: [OrderRadioButton], type: OrderSectionType) {
        self.items = items
        self.type = type
    }
}

