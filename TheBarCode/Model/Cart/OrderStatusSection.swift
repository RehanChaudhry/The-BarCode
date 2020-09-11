//
//  OrderStatusInfo.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

class OrderStatusInfo: NSObject {
    
    var orderNo: String

    var status: String

    init(orderNo: String, status: String) {
        self.orderNo = orderNo
        self.status = status
    }
}

class OrderStatusSection: OrderViewModel {
  
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType {
        return .statusHeading
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderStatusInfo]
    
    init(items: [OrderStatusInfo]) {
        self.items = items
    }
}
