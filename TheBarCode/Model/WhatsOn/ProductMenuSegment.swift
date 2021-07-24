//
//  FoodMenuSegment.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import ObjectMapper

enum ProductMenuType: String {
    case dineIn = "dineIn", takeAwaydelivery = "takeAwaydelivery"
}

struct ProductMenuSegmentMappingContext: MapContext {
    var type: ProductMenuType
}

class ProductMenuSegment: Mappable {
    
    var id: String!
    var name: String!
    var products: [Product] = []
    
    var isExpanded: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.id = "\(map.JSON["id"]!)"
        self.name = map.JSON["name"] as? String ?? "Other"
        
        let mapContext = map.context as! ProductMenuSegmentMappingContext
        
        let items = map.JSON["items"] as? [[String : Any]] ?? []
        let importedProducts = try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> [Product] in
            
            var importedProducts: [Product] = []
            
            for item in items {
                var itemData: [String : Any] = item
                itemData["contextual_id"] = Product.getContextulId(source: itemData,
                                                                   mapContext: mapContext)
                
                let product = try! transaction.importUniqueObject(Into<Product>(), source: itemData)
                importedProducts.append(product!)
            }
            
            return importedProducts
        })
        
        self.products.removeAll()
        for product in importedProducts {
            let fetchedFood = Utility.barCodeDataStack.fetchExisting(product)!
            self.products.append(fetchedFood)
        }
    }
}
