//
//  AllSearchFooterViewModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchFooterViewModel {
    
    var shouldShowSeparator: Bool
    var shouldShowExpandButton: Bool
    var shouldShowViewMoreButon: Bool
    
    var footerStrokeColor: UIColor
    
    init(shouldShowSeparator: Bool, shouldShowExpandButton: Bool, shouldShowViewMoreButon: Bool, footerStrokeColor: UIColor) {
        self.shouldShowSeparator = shouldShowSeparator
        self.shouldShowExpandButton = shouldShowExpandButton
        self.shouldShowViewMoreButon = shouldShowViewMoreButon
        self.footerStrokeColor = footerStrokeColor
    }
    
}
