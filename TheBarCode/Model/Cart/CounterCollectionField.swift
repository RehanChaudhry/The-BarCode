//
//  CounterCollectionField.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 17/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit

class CounterCollectionField: NSObject {
    
    var text: String = ""
}

class CounterCollectionFieldSection: OrderViewModel {
    var shouldShowSeparator: Bool {
        return false
    }

    var type: OrderSectionType

    var rowCount: Int {
        return self.items.count
    }

    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }

    var items: [CounterCollectionField]

    init(items: [CounterCollectionField], type: OrderSectionType) {
        self.items = items
        self.type = type
    }
}
