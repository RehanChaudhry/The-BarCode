//
//  AllSearchFoodModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchProductModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType
    var product: Product
    
    var bar: Bar
    
//    var isInAppPaymentOn: Bool
//    var menuTypeRaw: String
//
//    var barId: String
    
    init(type: AllSearchSectionViewModelItemType, product: Product, bar: Bar) {
        self.type = type
        self.product = product
        
        self.bar = bar
        
//        self.isInAppPaymentOn = isInAppPaymentOn
//
//        self.barId = barId
//        self.menuTypeRaw = menuTypeRaw
    }
}
