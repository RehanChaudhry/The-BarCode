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
    
    var isInAppPaymentOn: Bool
    var menuTypeRaw: String
    
    var barId: String
    
    init(type: AllSearchSectionViewModelItemType, product: Product, isInAppPaymentOn: Bool, barId: String, menuTypeRaw: String) {
        self.type = type
        self.product = product
        self.isInAppPaymentOn = isInAppPaymentOn
        
        self.barId = barId
        self.menuTypeRaw = menuTypeRaw
    }
}
