//
//  AllSearchFoodModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchFoodModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType
    var food: Food
    
    var isInAppPaymentOn: Bool
    
    init(type: AllSearchSectionViewModelItemType, food: Food, isInAppPaymentOn: Bool) {
        self.type = type
        self.food = food
        self.isInAppPaymentOn = isInAppPaymentOn
    }
}
