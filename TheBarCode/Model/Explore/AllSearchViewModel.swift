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

/*
enum AllSearchFooterType: String {
    case none = "none",
    singleLine = "singleLine",
    viewMore = "viewMore",
    
    expandableWithViewMore = "expandableWithViewMore",
    
    expandableWithoutViewMoreWithSeparator = "expandableWithoutViewMoreWithSeparator",
    expandableWithoutViewMoreWithOutSeparator = "expandableWithoutViewMoreWithOutSeparator"
}*/

protocol AllSearchViewModelItem: class {
    var type: AllSearchItemType { get }
    var sectionTitle: String? { get }
    var rowCount: Int { get }
    
    var headerStrokeColor: UIColor { get }
    var footerModel: AllSearchFooterViewModel { get }
}



class AllSearchViewModelTypeBar: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopeYellowColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.bar
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerModel: AllSearchFooterViewModel
    
    init(sectionTitle: String?, items: [Bar], footerModel: AllSearchFooterViewModel) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
    
}

class AllSearchViewModelTypeDeal: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopeOrangeColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.deal
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerModel: AllSearchFooterViewModel
    
    init(sectionTitle: String?, items: [Bar], footerModel: AllSearchFooterViewModel) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
    
}

class AllSearchViewModelTypeLiveOffer: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopeBlueColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.liveOffer
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerModel: AllSearchFooterViewModel
    
    init(sectionTitle: String?, items: [Bar], footerModel: AllSearchFooterViewModel) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
    
}

class AllSearchViewModelTypeFood: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopePurpleColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Food] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.food
    }
    
    var rowCount: Int {
        if self.items.count > 3 {
            if self.isExpanded {
                return self.items.count
            } else {
                return 3
            }
        } else {
            return self.items.count
        }
    }
    
    var footerModel: AllSearchFooterViewModel
    
    var isExpanded = false
    
    init(sectionTitle: String?, items: [Food], footerModel: AllSearchFooterViewModel) {
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
}

class AllSearchViewModelTypeDrink: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopePinkColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Drink] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.drink
    }
    
    var rowCount: Int {
        if self.items.count > 3 {
            if self.isExpanded {
                return self.items.count
            } else {
                return 3
            }
        } else {
            return self.items.count
        }
    }
    
    var footerModel: AllSearchFooterViewModel
    
    var isExpanded = false
    
    init(sectionTitle: String?, items: [Drink], footerModel: AllSearchFooterViewModel) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
}

class AllSearchViewModelTypeEvent: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            return UIColor.appSearchScopeGreenColor()
        }
    }
    
    var sectionTitle: String?
    var items: [Event] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.event
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerModel: AllSearchFooterViewModel
    
    init(sectionTitle: String?, items: [Event], footerModel: AllSearchFooterViewModel) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
    }
}

class AllSearchViewModelTypeFoodBar: AllSearchViewModelItem {
    
    var headerStrokeColor: UIColor {
        get {
            if self.isDrink {
                return UIColor.appSearchScopePinkColor()
            } else {
                return UIColor.appSearchScopePurpleColor()
            }
        }
    }
    
    var sectionTitle: String?
    var items: [Bar] = []
    
    var type: AllSearchItemType {
        return AllSearchItemType.foodBar
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var footerModel: AllSearchFooterViewModel
    
    var isDrink: Bool
    
    init(sectionTitle: String?, items: [Bar], footerModel: AllSearchFooterViewModel, isDrink: Bool) {
        
        self.sectionTitle = sectionTitle
        self.items = items
        self.footerModel = footerModel
        self.isDrink = isDrink
    }
}


