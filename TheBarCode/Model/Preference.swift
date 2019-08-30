//
//  Preference.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class Preference: NSObject {
    
    var category: Category
    var subPreferences: [Preference]
    
    init(category: Category, subPreferences: [Preference]) {
        self.category = category
        self.subPreferences = subPreferences
    }
}
