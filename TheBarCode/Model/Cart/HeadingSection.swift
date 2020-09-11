//
//  HeadingSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation

//MARK: Heading e.g Payment split
class Heading: NSObject {
    
    var title: String = ""

    init(title: String) {
        self.title = title
    }
}

class HeadingSection: OrderViewModel {
    
    var shouldShowSeparator: Bool {
           return false
    }
    
    var type: OrderSectionType {
        return .heading
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [Heading]
    
    init(items: [Heading]) {
        self.items = items
    }
}
