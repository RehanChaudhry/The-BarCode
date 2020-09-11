//
//  OrderTotalBillInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: totalbill Section
class OrderBillInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
    var shouldRoundCorners: Bool = false
    var showWithBlackAppearance: Bool = false
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
}

class OrderTotalBillInfoSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .totalBill
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
