//
//  OrderMessageSection.swift
//  TheBarCode
//
//  Created by Mac OS X on 14/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderMessage {
    var message: NSAttributedString
    
    init(message: NSAttributedString) {
        self.message = message
    }
}

class OrderMessageSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .messageBoard
    }

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [OrderMessage]

    init(items: [OrderMessage]) {
        self.items = items
    }
}
