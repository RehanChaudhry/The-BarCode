//
//  FoodSearch.swift
//  TheBarCode
//
//  Created by Mac OS X on 24/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class ScopeSearchResult: NSObject {

    var bar: Bar
    
    var products: [Product]
    
    var events: [Event]
    
    var isExpanded: Bool = false
    
    init(bar: Bar, foods: [Product]) {
        self.bar = bar
        self.products = foods
        self.events = []
    }
    
    init(bar: Bar, events: [Event]) {
        self.bar = bar
        self.products = []
        self.events = events
    }
}
