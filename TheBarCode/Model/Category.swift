//
//  Category.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class Category: NSObject {
    
    var title: String = ""
    var image: String = ""
    
    var isSelected: Bool = false
    
    init(title: String, image: String, isSelected: Bool) {
        super.init()
        
        self.title = title
        self.image = image
        self.isSelected = isSelected
    }
}
