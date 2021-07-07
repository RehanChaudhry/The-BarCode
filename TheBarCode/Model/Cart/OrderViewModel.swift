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
    percentSplitField = "percentSplitField",
    messageBoard = "messageBoard",
    mobileNumber = "mobileNumber"
}

protocol OrderViewModel: class {
    
    var shouldShowSeparator: Bool { get }

    var type: OrderSectionType { get }
    
    var rowCount: Int { get }
    
    var rowHeight: CGFloat { get }
}


//MARK: BarDetails
class BarInfo: NSObject {
    
    var barName: String
    var orderType: OrderType

    init(barName: String, orderType: OrderType) {
        self.barName = barName
        self.orderType = orderType
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

//MARK: TipDetails

class TipInfo: NSObject {
    
    var tipLabel: String
    var tipAmount: String
    var orderType: OrderType

    init(tipLabel: String, tipAmount: String, orderType: OrderType) {
        self.tipLabel = tipLabel
        self.tipAmount = tipAmount
        self.orderType = orderType
    }
}

class TipInfoSection: OrderViewModel {
    
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
    
    var items: [TipInfo]
    
    init(items: [TipInfo]) {
        self.items = items
    }
}








