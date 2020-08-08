//
//  Address.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 07/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class Address: NSObject {
    
    var label: String
    var address: String
    var additionalInfo: String
    
    var city: String
    
    var isSelected: Bool = false
    
    init(label: String, address: String, additionalInfo: String, city: String) {
        self.label = label
        self.address = address
        self.additionalInfo = additionalInfo
        self.city = city
    }
}

extension Address {
    static func dummy() -> [Address] {
        let home = Address(label: "Home", address: "L - 591 Sector 11-A North Karachi", additionalInfo: "First floor", city: "Karachi")
        let work = Address(label: "Work", address: "Central commercial area, Shahrah-E-Faisal", additionalInfo: "Mezzanine floor", city: "Karachi")
        let other = Address(label: "Other", address: "11-B Creekvista Defence phase 8", additionalInfo: "8th floor", city: "Karachi")
        return [home, work, other]
    }
}
