//
//  MenuItem.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/03/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

enum MenuItemType: String {
    
    case invite = "invite",
    myReservations = "myReservations",
    splitPayment = "splitPayment",
    notification = "notification",
    accountSettings = "accountSettings",
    notificationSettings = "notificationSettings",
    preferences = "preferences",
    reload = "reload",
    faqs = "faqs",
    rules = "rules",
    privacyPolicy = "privacyPolicy",
    signOut = "signOut"
    
    func description() -> (title: String, icon: String?, storyboardId: String, showSeparator: Bool, fontSize: Float) {
        switch self {
        case .invite:
            return ("Invite", "icon_invite", "InviteNavigation", true, 16.0)
        case .myReservations:
            return ("My Reservations", "icon_reservation", "MyReservationsNavigation", true, 16.0)
        case .splitPayment:
            return ("Split Payment Scanner", "icon_split_payment", "AccountSettingsNavigation", true, 16.0)
        case .notification:
            return ("Notifications", "icon_notification", "NotificationNavigation", true, 16.0)
        case .accountSettings:
            return ("Account Settings", "icon_account_settings", "AccountSettingsNavigation", true, 16.0)
        case .notificationSettings:
            return ("Notification Settings", "icon_notif_settings", "NotificationSettingsNavigation", true, 16.0)
        case .preferences:
            return ("Preferences", "icon_preferences", "CategoryFilterNavigation", true, 16.0)
        case .reload:
            return ("Reload", "icon_reload", "ReloadNavigation", true, 16.0)
        case .faqs:
            return ("Frequently Asked Questions", "icon_faq", "FaqsNavigation", true, 16.0)
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
        MenuItem(type: .invite),
        MenuItem(type: .myReservations),
        MenuItem(type: .splitPayment),
        MenuItem(type: .notification),
        MenuItem(type: .accountSettings),
        MenuItem(type: .notificationSettings),
        MenuItem(type: .preferences),
        MenuItem(type: .reload),
        MenuItem(type: .faqs),
        MenuItem(type: .rules),
        MenuItem(type: .privacyPolicy),
        MenuItem(type: .signOut),
        ]
    }
    
}

class MenuItem: NSObject {
    
    var type: MenuItemType!
    
    init(type: MenuItemType) {
        
        self.type = type

    }
}
