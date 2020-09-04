//
//  Country.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 13/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class Country: NSObject {
    
    var id: String
    var name: String
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
    
    static func allCountries() -> [Country] {
        return [Country(id: "1", name: "England"),
                Country(id: "2", name: "Scotland"),
                Country(id: "3", name: "Wales"),
                Country(id: "4", name: "Northern Ireland")]
    }
    
}
