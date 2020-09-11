//
//  OrderSplitAmountInfoSection.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderSplitAmountInfoSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .splitAmount
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderBillInfo]
    
    init(items: [OrderBillInfo]) {
        self.items = items
    }
    
}
