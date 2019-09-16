//
//  AllSearchEventModel.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class AllSearchEventModel: AllSearchSectionViewModelItem {
    
    var type: AllSearchSectionViewModelItemType
    var event: Event
    
    init(event: Event, type: AllSearchSectionViewModelItemType) {
        self.event = event
        self.type = type
    }
    
}
