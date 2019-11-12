//
//  SearchScope.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

enum SearchScope: String {
    
    case all = "all",
    bar = "bars",
    deal = "deals",
    liveOffer = "live_offers",
    food = "food",
    drink = "drink",
    event = "event"
    
    func item() -> SearchScopeItem {
        switch self {
        case .all:
            let item = SearchScopeItem(storyboardId: "AllSearchViewController",
                                       scopeType: .all,
                                       title: "ALL",
                                       backgroundColor: .appGrayColor(),
                                       selectedBackgroundColor: .black)
            return item
        case .bar:
            let item = SearchScopeItem(storyboardId: "BarSearchViewController",
                                       scopeType: .bar,
                                       title: "BARS",
                                       backgroundColor: .appSearchScopeBarsColor(),
                                       selectedBackgroundColor: .appSearchScopeBarsSelectedColor())
            return item
        case .deal:
            let item = SearchScopeItem(storyboardId: "DealSearchViewController",
                                       scopeType: .deal,
                                       title: "DEALS",
                                       backgroundColor: .appSearchScopeDealsColor(),
                                       selectedBackgroundColor: .appSearchScopeDealsSelectedColor())
            return item
        case .liveOffer:
            let item = SearchScopeItem(storyboardId: "LiveOfferSearchViewController",
                                       scopeType: .liveOffer,
                                       title: "LIVE OFFERS",
                                       backgroundColor: .appSearchScopeLiveOffersColor(),
                                       selectedBackgroundColor: .appSearchScopeLiveOffersSelectedColor())
            return item
        case .food:
            let item = SearchScopeItem(storyboardId: "FoodSearchViewController",
                                       scopeType: .food,
                                       title: "FOOD",
                                       backgroundColor: .appSearchScopeFoodsColor(),
                                       selectedBackgroundColor: .appSearchScopeFoodsSelectedColor())
            return item
        case .drink:
            let item = SearchScopeItem(storyboardId: "DrinkSearchViewController",
                                       scopeType: .drink,
                                       title: "DRINKS",
                                       backgroundColor: .appSearchScopeDrinksColor(),
                                       selectedBackgroundColor: .appSearchScopeDrinksSelectedColor())
            return item
        case .event:
            let item = SearchScopeItem(storyboardId: "EventSearchViewController",
                                       scopeType: .event,
                                       title: "EVENTS",
                                       backgroundColor: .appSearchScopeEventsColor(),
                                       selectedBackgroundColor: .appSearchScopeEventsSelectedColor())
            return item
        }
    }
    
    static func allItems() -> [SearchScopeItem] {
        return [SearchScope.all.item(),
                SearchScope.bar.item(),
                SearchScope.deal.item(),
//                SearchScope.liveOffer.item(),
                SearchScope.food.item(),
                SearchScope.drink.item(),
                SearchScope.event.item()
        ]
    }
}

class SearchScopeItem: NSObject {
    
    var storyboardId: String
    var scopeType: SearchScope
    var title: String
    
    var backgroundColor: UIColor
    var selectedBackgroundColor: UIColor
    
    var isSelected: Bool = false
    
    lazy var controller: BaseSearchScopeViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = (storyboard.instantiateViewController(withIdentifier: self.storyboardId) as! BaseSearchScopeViewController)
        return controller
    }()
    
    init(storyboardId: String, scopeType: SearchScope, title: String, backgroundColor: UIColor, selectedBackgroundColor: UIColor) {
        self.storyboardId = storyboardId
        self.scopeType = scopeType
        self.title = title
        
        self.backgroundColor = backgroundColor
        self.selectedBackgroundColor = selectedBackgroundColor
    }
}
