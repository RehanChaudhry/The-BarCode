//
//  OrderView.swift
//  TheBarCode
//
//  Created by Macbook on 20/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

enum OrderSectionType: String {
    case statusHeading = "statusHeading",
    barDetails = "barDetails",
    productDetails = "productDetails",
    discountDetails = "discountDetails",
    deliveryChargesDetails = "deliveryChargesDetails",
    totalBill = "totalBill",
    splitAmount = "splitAmount",
    heading = "heading",
    payment = "payment",
    reservationDetails = "reservationDetails",
    reservationStatus = "reservationStatus",
    vouchers = "vouchers",
    offers = "offers",
    offerRedeem = "offerRedeem",
    discountInfo = "discountInfo",
    dineIn = "dineIn",
    tableNo = "tableNo",
    counterCollection = "counterCollection",
    takeAway = "takeAway",
    delivery = "delivery",
    deliveryAddress = "deliveryAddress",
    equalSplit = "equalSplit",
    fixedAmountSplit = "fixedAmountSplit",
    percentSplit = "percentSplit",
    fixedAmountSplitField = "fixedAmountSplitField",
    percentSplitField = "percentSplitField"
}

protocol OrderViewModel: class {
    
    var shouldShowSeparator: Bool { get }

    var type: OrderSectionType { get }
    
    var rowCount: Int { get }
    
    var rowHeight: CGFloat { get }
}


//MARK: BarDetails
class BarInfo: NSObject {
    
    var barName: String = ""

    init(barName: String) {
        self.barName = barName
    }
}

class BarInfoSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return true
    }
    
    var type: OrderSectionType {
        return .barDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [BarInfo]
    
    init(items: [BarInfo]) {
        self.items = items
    }
}







