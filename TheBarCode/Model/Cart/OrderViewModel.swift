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
    heading = "heading",
    payment = "payment"
}

protocol OrderViewModel: class {
    
    var shouldShowSeparator: Bool { get }

    var type: OrderSectionType { get }
    
    var rowCount: Int { get }
    
    var rowHeight: CGFloat { get }
}

//MARK: OrderStatusInfo e.g ORDER #
class OrderStatusInfo: NSObject {
    
    var orderNo: String = ""

    var status: OrderStatus =  .other

    init(orderNo: String, status: OrderStatus) {
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


//MARK: Product
class OrderProductsInfoSection: OrderViewModel {
   
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .productDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderItem]
    
    init(items: [OrderItem]) {
        self.items = items
    }
}

//MARK: Discount
class OrderDiscountInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
}

class OrderDiscountSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .discountDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderDiscountInfo]
    
    init(items: [OrderDiscountInfo]) {
        self.items = items
    }
    
}

//MARK: Delivery Section
class OrderDeliveryInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
}

class OrderDeliveryInfoSection: OrderViewModel {
   
    var shouldShowSeparator: Bool {
        return true
    }
    
    var type: OrderSectionType {
        return .deliveryChargesDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderDeliveryInfo]
    
    init(items: [OrderDeliveryInfo]) {
        self.items = items
    }
}


//MARK: totalbill Section
class OrderTotalBillInfo: NSObject {
    
    var title: String = ""

    var price: Double = 0.0
    
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
    
    var items: [OrderTotalBillInfo]
    
    init(items: [OrderTotalBillInfo]) {
        self.items = items
    }
}

//MARK: Heading e.g Payment split
class Heading: NSObject {
    
    var title: String = ""

    init(title: String) {
        self.title = title
    }
}

class HeadingSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
           return false
       }
    
    var type: OrderSectionType {
        return .heading
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [Heading]
    
    init(items: [Heading]) {
        self.items = items
    }
}

//MARK: Payment
class OrderPaymentInfo: NSObject {
    
    var title: String = ""

    var percentage: Int = 0
    var status: String = ""
    var price: Double = 0.0

    init(title: String, percentage: Int, status: String, price: Double) {
        self.title = title
        self.percentage = percentage
        self.status = status
        self.price = price
    }
}

class OrderPaymentInfoSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
           return false
    }
    
    var type: OrderSectionType {
        return .payment
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderPaymentInfo]
    
    init(items: [OrderPaymentInfo]) {
        self.items = items
    }
}
