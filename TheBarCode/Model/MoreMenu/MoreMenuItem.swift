//
//  MenuItem.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/03/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

enum MenuItemType: String {
    
    case accountSettings = "accountSettings",
    notificationSettings = "notificationSettings",
    sharedOffer = "sharedOffer",
    preferences = "preferences",
    reload = "reload",
    faqs = "faqs",
    rules = "rules",
    privacyPolicy = "privacyPolicy",
    signOut = "signOut"
    
    
    func description() -> (title: String, icon: String?, storyboardId: String, showSeparator: Bool, fontSize: Float) {
        switch self {
        case .accountSettings:
            return ("Account Settings", "icon_account_settings", "AccountSettingsNavigation", true, 16.0)
        case .notificationSettings:
            return ("Notification Settings", "icon_notification_settings", "NotificationSettingsNavigation", true, 16.0)
        case .sharedOffer:
            return ("Shared Offers", "icon_shared_offer", "SharedOffersNavigation", true, 16.0)
        case .preferences:
            return ("Preferences", "icon_preference", "PreferencesNavigation", true, 16.0)
        case .reload:
            return ("Reload", "icon_reload", "ReloadNavigation", true, 16.0)
        case .faqs:
            return ("Frequently Asked Questions", "icon_faqs", "FaqsNavigation", true, 16.0)
        case .rules:
            return ("Redemption & Reload Rules", "icon_rules", "RulesNavigation", true, 16.0)
        case .privacyPolicy:
            return ("Privacy Policy", "icon_privacy", "PrivacyNavigation", true, 16.0)
        case .signOut:
            return ("Sign Out", "icon_signout", "", false, 16.0)
            
        }
    }
    
    static func allMenuItems() -> [MenuItem] {
        return [
//        MenuItem(type: .sharedOffer),
        MenuItem(type: .accountSettings),
        MenuItem(type: .notificationSettings),
        MenuItem(type: .preferences),
        MenuItem(type: .reload),
        MenuItem(type: .faqs),
        MenuItem(type: .rules),
        MenuItem(type: .privacyPolicy),
        MenuItem(type: .signOut)
        ]
    }
    
}

class MenuItem: NSObject {
    
    var type: MenuItemType!
    
    init(type: MenuItemType) {
        
        self.type = type

    }
}
