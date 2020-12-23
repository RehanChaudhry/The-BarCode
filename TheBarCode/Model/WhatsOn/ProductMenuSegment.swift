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

class ProductMenuSegment: Mappable {
    
    var id: String!
    var name: String!
    var foods: [Product] = []
    
    var isExpanded: Bool = false
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.id = "\(map.JSON["id"]!)"
        self.name = map.JSON["name"] as? String ?? "Other"
        
        let items = map.JSON["items"] as? [[String : Any]] ?? []
        let importedFoods = try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> [Product] in
            let importedFoods = try! transaction.importUniqueObjects(Into<Product>(), sourceArray: items)
            return importedFoods
        })
        
        self.foods.removeAll()
        for food in importedFoods {
            let fetchedFood = Utility.barCodeDataStack.fetchExisting(food)!
            self.foods.append(fetchedFood)
        }
    }
}
