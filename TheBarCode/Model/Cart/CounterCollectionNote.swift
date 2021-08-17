////
////  CounterCollectionNote.swift
////  TheBarCode
////
////  Created by Rehan Chaudhry on 13/08/2021.
////  Copyright © 2021 Cygnis Media. All rights reserved.
////
//
//import Foundation
//
////
////  OrderMessageSection.swift
////  TheBarCode
////
////  Created by Mac OS X on 14/09/2020.
////  Copyright © 2020 Cygnis Media. All rights reserved.
////
//
//import UIKit
//
//class CounterCollectionNote {
//    var message: String? = ""
//    
//    init(message: String) {
//        self.message = message
//    }
//}
//
//class CounterCollectionNoteSection: OrderViewModel {
//    var shouldShowSeparator: Bool {
//        return false
//    }
//
//    var type: OrderSectionType {
//        return .counterCollection
//    }
//
//    var rowCount: Int {
//        return self.items.count
//    }
//
//    var rowHeight: CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    var items: [CounterCollectionNote]
//
//    init(items: [CounterCollectionNote]) {
//        self.items = items
//    }
//}
