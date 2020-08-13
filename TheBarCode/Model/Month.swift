//
//  Month.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 13/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

enum Month : Int  {
    case january = 1,
    february,
    march,
    april,
    may,
    june,
    july,
    august,
    september,
    october,
    november,
    december
    
    static let allValues = [january, february, march, april, may, june, july, august, september, october, november, december]
    
    func displayableValue() -> (full: String, numeric: String) {
        switch self {
        case .january:
            return ("January" , "01")
        case .february:
            return ("February", "02")
        case .march:
            return ("March", "03")
        case .april:
            return ("April", "04")
        case .may:
            return ("May", "05")
        case .june:
            return ("June", "06")
        case .july:
            return ("July", "07")
        case .august:
            return ("August", "08")
        case .september:
            return ("September", "09")
        case .october:
            return ("October", "10")
        case .november:
            return ("November", "11")
        case .december:
            return ("December", "12")
        }
    }
     
}
