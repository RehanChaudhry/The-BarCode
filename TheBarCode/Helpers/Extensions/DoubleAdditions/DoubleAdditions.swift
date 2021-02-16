//
//  DoubleAdditions.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/01/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import Foundation

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
