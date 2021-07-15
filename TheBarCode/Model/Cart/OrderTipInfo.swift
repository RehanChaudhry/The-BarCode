//
//  OrderTotalBillInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: totalbill Section
class OrderTipInfo: NSObject {
    
    var title: String = ""

    var tipAmount: Double = 0.0
    
    var shouldRoundCorners: Bool = false
    var showWithBlackAppearance: Bool = false
    
    init(title: String, tipAmount: Double) {
        self.title = title
        self.tipAmount = tipAmount
    }
}

class OrderTipInfoSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .orderTip
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderTipInfo]
    
    init(items: [OrderTipInfo]) {
        self.items = items
    }
}

