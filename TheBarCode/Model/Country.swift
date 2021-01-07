//
//  Country.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 13/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import SquareBuyerVerificationSDK

class Country: NSObject {
    
    var id: String
    var name: String
    var code: SQIPCountry
    
    init(id: String, name: String, code: SQIPCountry) {
        self.id = id
        self.name = name
        self.code = code
    }
    
    static func allCountries() -> [Country] {
        return [Country(id: "1", name: "England", code: SQIPCountry.GB),
                Country(id: "2", name: "Scotland", code: SQIPCountry.GB),
                Country(id: "3", name: "Wales", code: SQIPCountry.GB),
                Country(id: "4", name: "Northern Ireland", code: SQIPCountry.GB)]
    }
    
}
