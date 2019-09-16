//
//  AllSearchExpandModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchExpandModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType
    var isExpanded: Bool
    var expandableItems: [AllSearchSectionViewModelItem]
    
    init(type: AllSearchSectionViewModelItemType, isExpanded: Bool, expandableItems: [AllSearchSectionViewModelItem]) {
        self.type = type
        self.isExpanded = isExpanded
        self.expandableItems = expandableItems
    }
}
