//
//  Bar.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class Bar: Explore {
    let fiveADayDeal = Relationship.ToManyOrdered<Deal>("fiveADayDeal", inverse: { $0.establishment })
}
