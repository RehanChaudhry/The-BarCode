//
//  AllSearchViewModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 25/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

enum AllSearchItemType: String {
    case bar = "bar",
    deal = "deal",
    liveOffer = "liveOffer",
    food = "food",
    drink = "drink",
    event = "event",
    foodBar = "foodBar"
}

enum AllSearchFooterType: String {
    case none = "none",
    singleLine = "singleLine",
    viewMore = "viewMore"
}

protocol AllSearchViewModelItem: class {
    var type: AllSearchItemType { get }
    var sectionTitle: String? { get }
    var rowCount: Int { get }
    var footerType: AllSearchFooterType { get }
}

class AllSearchViewModelTypeBar: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.bar
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Bar], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
    
}

class AllSearchViewModelTypeDeal: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.deal
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Bar], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
    
}

class AllSearchViewModelTypeLiveOffer: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.liveOffer
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Bar], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
    
}

class AllSearchViewModelTypeFood: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Food] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.food
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Food], footerType: AllSearchFooterType) {
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
}

class AllSearchViewModelTypeDrink: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Drink] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.drink
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Drink], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
}

class AllSearchViewModelTypeEvent: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Event] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.event
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Event], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
}

class AllSearchViewModelTypeFoodBar: AllSearchViewModelItem {
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.foodBar
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerType: AllSearchFooterType
    
    init(sectionTitle: String?, items: [Bar], footerType: AllSearchFooterType) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerType = footerType
    }
}


