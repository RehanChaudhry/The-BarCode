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
        return self.isExpanded ? self.rows.count : 1
    }
    
    var rowHeight: CGFloat {
        return UITableViewAutomaticDimension
    }
    
    var rows: [Any] = []
    
    var selectedModifiers: [ProductModifier] = []
    
    var item: OrderItem!
    
    var isExpanded: Bool = false
    
    var isExpandable: Bool {
        get {
            return self.rows.count > 1
        }
    }
    
    init(item: OrderItem) {
        self.item = item
        
        if item.selectedProductModifiers.count > 0 {
            self.selectedModifiers = item.selectedProductModifiers
        }

        self.rows.append(item)
        self.rows.append(contentsOf: self.selectedModifiers)
    }
}
