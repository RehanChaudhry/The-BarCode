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
    var drinks: [Drink]
    var foods: [Food]
    var events: [Event]
    
    var isExpanded: Bool = false
    
    init(bar: Bar, foods: [Food]) {
        self.bar = bar
        self.foods = foods
        self.drinks = []
        self.events = []
    }
    
    init(bar: Bar, drinks: [Drink]) {
        self.bar = bar
        self.drinks = drinks
        self.foods = []
        self.events = []
    }
    
    init(bar: Bar, events: [Event]) {
        self.bar = bar
        self.drinks = []
        self.foods = []
        self.events = events
    }
}
