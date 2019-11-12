//
//  DrinkMenuSegment.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreStore

class DrinkMenuSegment: Mappable {
    
    var id: String!
    var name: String!
    var drinks: [Drink] = []
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        self.id = "\(map.JSON["id"]!)"
        self.name = map.JSON["name"] as? String ?? "Other"
        
        let items = map.JSON["items"] as? [[String : Any]] ?? []
        let importedDrinks = try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> [Drink] in
            let importedDrinks = try! transaction.importUniqueObjects(Into<Drink>(), sourceArray: items)
            return importedDrinks
        })
        
        self.drinks.removeAll()
        for drink in importedDrinks {
            let fetchedDrink = Utility.barCodeDataStack.fetchExisting(drink)!
            self.drinks.append(fetchedDrink)
        }
    }
}
