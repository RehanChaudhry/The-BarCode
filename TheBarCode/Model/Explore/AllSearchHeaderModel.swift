//
//  AllSearchHeaderModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class AllSearchHeaderModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType {
        return .headerCell
    }

    var title: String
    
    init(title: String) {
        self.title = title
    }
}
