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
    
//    let fiveADayDeal = Relationship.ToOne<FiveADayDeal>("fiveADayDeal", inverse: {$0.establishment})
    
   let fiveADayDeal = Relationship.ToManyOrdered<Deal>("fiveADayDeal", inverse: { $0.establishment })
}
    
    
    
    
    
    //T##(FiveADayDeal) -> RelationshipContainer<FiveADayDeal>.ToOne<Bar>
    
    /*
    var isFavourite: Bool = false
    
    init(coverImage: String,title: String!, distance: String,  isFavourite: Bool = false) {
        super.init(coverImage: coverImage, title: title, distance: distance)
        self.isFavourite = isFavourite
    }
    
    
    static func getDummyList () -> [Bar] {
        let bar1 = Bar(coverImage: "home-bar1", title: "Neighbourhood", distance: "4 miles away")
        let bar2 = Bar(coverImage: "home-bar2", title: "The Blue Bar at The Berkeley", distance: "6 miles away")
        let bar3 = Bar(coverImage: "home-bar3", title: "The Punch Room", distance: "7 miles away")
        let bar4 = Bar(coverImage: "home-bar4", title: "Mr Fogg's Residence", distance: "8 miles away")
        let bar5 = Bar(coverImage: "home-bar5", title: "The Devil's Advocate", distance: "8.5 miles away")
        
        let bars = [bar1, bar2, bar3, bar4, bar5]
        return bars
    }
    
    static func getDummyFavList () -> [Bar] {
        let bar1 = Bar(coverImage: "fav1", title: "Ye Olde Fighting Cocks", distance: "4 miles away", isFavourite: true)
        let bar2 = Bar(coverImage: "fav2", title: "Bramble Bar & Lounge", distance: "6 miles away", isFavourite: true)
        let bar3 = Bar(coverImage: "fav3", title: "All Bar One", distance: "7 miles away", isFavourite: true)
        
        let bars = [bar1, bar2, bar3]
        return bars
    }
    
    static func getBar () -> Bar {
        let bar1 = Bar(coverImage: "fav1", title: "Ye Olde Fighting Cocks", distance: "4 miles away")
        return bar1
    }*/


//extension Bar {
//    
//   typealias ImportSource = [String: Any]
//    
//  func updateInCoreStore(source: [String : Any], transaction: BaseDataTransaction) {
//        
//        if let item = source["fiveADayDeal"] as? [String : Any] {
//            let importedObject = try! transaction.importUniqueObject(Into<FiveADayDeal>(), source: item)
//            
//            if importedObject != nil {
//                self.fiveADayDeal.value = importedObject
//            }
//        }
//        
//    }
//}
