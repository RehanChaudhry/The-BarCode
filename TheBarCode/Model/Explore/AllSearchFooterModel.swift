//
//  AllSearchFooterModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchViewMoreModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType {
        get {
            return .viewMoreCell
        }
    }

    var footerStrokeColor: UIColor
    
    init(footerStrokeColor: UIColor) {
        self.footerStrokeColor = footerStrokeColor
    }
    
}
