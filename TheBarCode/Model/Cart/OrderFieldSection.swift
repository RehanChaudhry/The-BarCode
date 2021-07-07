//
//  OrderFieldSection.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderFieldInput: NSObject {
    
    var keyboardType: UIKeyboardType = .default
    
    var allowedCharacterSet: CharacterSet?
    
    var placeholder: String = ""
    
    var maxCharacters: Int = 100
    
    var text: String = ""
    
    var currencySymbol = ""
}

class OrderFieldSection: OrderViewModel {
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

    var items: [OrderFieldInput]

    init(items: [OrderFieldInput], type: OrderSectionType) {
        self.items = items
        self.type = type
    }
}
