//
//  AllSearchBarModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchBarModel: AllSearchSectionViewModelItem {

    var type: AllSearchSectionViewModelItemType
    var bar: Bar
    
    init(type: AllSearchSectionViewModelItemType, bar: Bar) {
        self.type = type
        self.bar = bar
    }
}
