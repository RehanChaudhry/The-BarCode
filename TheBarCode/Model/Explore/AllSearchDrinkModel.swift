//
//  AllSearchDrinkModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchDrinkModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType
    var drink: Drink
    
    init(type: AllSearchSectionViewModelItemType, drink: Drink) {
        self.type = type
        self.drink = drink
    }
}

