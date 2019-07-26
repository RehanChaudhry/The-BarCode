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
            let item = SearchScopeItem(storyboardId: "AllSearchViewController", scopeType: .all, title: "ALL")
            return item
        case .bar:
            let item = SearchScopeItem(storyboardId: "BarSearchViewController", scopeType: .bar, title: "BAR")
            return item
        case .deal:
            let item = SearchScopeItem(storyboardId: "DealSearchViewController", scopeType: .deal, title: "DEAL")
            return item
        case .liveOffer:
            let item = SearchScopeItem(storyboardId: "LiveOfferSearchViewController", scopeType: .liveOffer, title: "LIVE OFFER")
            return item
        case .food:
            let item = SearchScopeItem(storyboardId: "FoodSearchViewController", scopeType: .food, title: "FOOD")
            return item
        case .drink:
            let item = SearchScopeItem(storyboardId: "DrinkSearchViewController", scopeType: .drink, title: "DRINK")
            return item
        case .event:
            let item = SearchScopeItem(storyboardId: "EventSearchViewController", scopeType: .event, title: "EVENT")
            return item
        }
    }
    
    static func allItems() -> [SearchScopeItem] {
        return [SearchScope.all.item(),
                SearchScope.bar.item(),
                SearchScope.deal.item(),
                SearchScope.liveOffer.item(),
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
    
    var isSelected: Bool = false
    
    lazy var controller: BaseSearchScopeViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = (storyboard.instantiateViewController(withIdentifier: self.storyboardId) as! BaseSearchScopeViewController)
        return controller
    }()
    
    init(storyboardId: String, scopeType: SearchScope, title: String) {
        self.storyboardId = storyboardId
        self.scopeType = scopeType
        self.title = title
    }
}
