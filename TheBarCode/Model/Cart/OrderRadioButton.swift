//
//  OrderRadioButton.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class OrderRadioButton: NSObject {
    
    var title: String
    var subTitle: String
    var value: Double = 0.0
    
    var isSelected: Bool = false
    
    init(title: String, subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
    
}
