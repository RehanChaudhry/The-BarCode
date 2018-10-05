//
//  FiveADayDeal.swift
//  TheBarCode
//
//  Created by Aasna Islam on 04/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class FiveADayDeal: Deal {
    var location: String! = ""
    var subTitle: String! = ""
    
    init(location: String, subTitle: String, detail: String, coverImage: String, title: String!, distance: String) {
        super.init(detail: detail, coverImage: coverImage, title: title, distance: distance)
        self.location = location
        self.subTitle = subTitle
    }
    
    static func getDummyList () -> [FiveADayDeal] {
        let deal1 = FiveADayDeal(location: "The White Hart", subTitle: "2 smoothies for the price of 1", detail: "When you are in a hurry smoothies are a special blend of drinkable happiness. Come in for lunch and get 2 for 1 on smoothies.", coverImage: "fiveday-deal1", title: "Green Bean", distance: "4 miles away")
        
        let deal2 = FiveADayDeal(location: "The Rose and Crown", subTitle: "2 smoothies for the price of 1", detail: "When you are in a hurry smoothies are a special blend of drinkable happiness. Come in for lunch and get 2 for 1 on smoothies.", coverImage: "fiveday-deal2", title: "Strawberry Papaya Smoothie", distance: "2.5 miles away")
        
        let deal3 = FiveADayDeal(location: "The Imperial Dunbar", subTitle: "2 Coconut Green Smoothie for the price of 1", detail: "When you are in a hurry smoothies are a special blend of drinkable happiness. Come in for lunch and get 2 for 1 on smoothies.", coverImage: "fiveday-deal3", title: "Coconut Green Smoothie", distance: "6 miles away")
        
        
        let deals = [deal1, deal2, deal3]
        return deals
    }

    static func getFiveADayDeal () -> FiveADayDeal {
        let deal1 = FiveADayDeal(location: "The White Hart", subTitle: "2 smoothies for the price of 1", detail: "When you are in a hurry smoothies are a special blend of drinkable happiness. Come in for lunch and get 2 for 1 on smoothies.", coverImage: "deal1", title: "Green Bean", distance: "4 miles away")
        return deal1
    }

    

    
    
}
