//
//  OrderProductsInfoSection.swift
//  TheBarCode
//
//  Created by Macbook on 23/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import Foundation


//MARK: Product
class OrderProductsInfoSection: OrderViewModel {
   
    var shouldShowSeparator: Bool {
        return false
    }
    
    var type: OrderSectionType {
        return .productDetails
    }
    
    var rowCount: Int {
        return self.items.count
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var items: [OrderItem]
    
    init(items: [OrderItem]) {
        self.items = items
    }
}
