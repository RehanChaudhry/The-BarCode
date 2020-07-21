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
    productDetails = "productDetails",
    discountDetails = "discountDetails",
    deliveryChargesDetails = "deliveryChargesDetails",
    totalBill = "totalBill",
    heading = "heading",
    payment = "payment"
}

protocol OrderViewModel: class {
    
    var type: OrderSectionType { get }
    
    var rowCount: Int { get }
    
    var rowHeight: CGFloat { get }
}

//MARK: OrderStatusInfo
class OrderStatusInfo: NSObject {
    
    var orderNo: String = ""

    var status: OrderStatus =  .other

    init(orderNo: String, status: OrderStatus) {
        self.orderNo = orderNo
        self.status = status
    }
}

class OrderStatusSection: OrderViewModel {
    
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

//MARK: Heading e.g Payment split

class Heading: NSObject {
    
    var title: String = ""

    init(title: String) {
        self.title = title
    }
}

class HeadingSection: OrderViewModel {
    
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


//MARK: Product
class OrderProductsInfoSection: OrderViewModel {
    
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
