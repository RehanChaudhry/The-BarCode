//
//  AllSearchSectionViewModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

enum AllSearchItemType: String {
    case bar = "bar",
    deliveryBars = "deliveryBars",
    deal = "deal",
    liveOffer = "liveOffer",
    food = "food",
    drink = "drink",
    event = "event",
    foodBar = "foodBar"
}

enum AllSearchSectionViewModelItemType: String {
    case headerCell = "headerCell",
    footerCell = "footerCell",
    barCell = "barCell",
    deliveryBarCell = "deliveryBarCell",
    dealCell = "dealCell",
    liveOfferCell = "liveOfferCell",
    foodBarCell = "foodBarCell",
    drinkBarCell = "drinkBarCell",
    foodCell = "foodCell",
    drinkCell = "drinkCell",
    eventCell = "eventCell",
    viewMoreCell = "viewMoreCell"
}

protocol AllSearchSectionViewModel: class {
    
    var type: AllSearchItemType { get }
    
    var headerStrokeColor: UIColor { get }
        
    var sectionTitle: String? { get }
    
    var items: [AllSearchSectionViewModelItem] { get }
    
}

protocol AllSearchSectionViewModelItem: class {
    var type: AllSearchSectionViewModelItemType { get }
}

class AllSearchViewModel: AllSearchSectionViewModel {
    
    var type: AllSearchItemType
    
    var headerStrokeColor: UIColor
    
    var items: [AllSearchSectionViewModelItem] = []
    
    var sectionTitle: String?
    
    init(type: AllSearchItemType, sectionTitle: String?, items: [AllSearchSectionViewModelItem], headerStrokeColor: UIColor) {
        
        self.type = type
        self.sectionTitle = sectionTitle
        self.items = items
        
        self.headerStrokeColor = headerStrokeColor
    }
    
}

