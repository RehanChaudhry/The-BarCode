//
//  MenuItem.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/03/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

enum MenuItemType: String {
    
    case offerWallet = "offerWallet",
    myReservations = "myReservations",
    splitPayment = "splitPayment",
    notification = "notification",
    accountSettings = "accountSettings",
    myAddresses = "myAddresses",
    myCards = "myCards",
    notificationSettings = "notificationSettings",
    preferences = "preferences",
    reload = "reload",
    faqs = "faqs",
    rules = "rules",
    paymentSenseTermsAndConditions = "paymentSenseTermsAndConditions",
    privacyPolicy = "privacyPolicy",
    signOut = "signOut"
    
    func description() -> (title: String, icon: String?, storyboardId: String, showSeparator: Bool, fontSize: Float) {
        switch self {
        case .offerWallet:
            return ("Wallet", "icon_tab_wallet", "OfferWalletNavigation", true, 16.0)
        case .myReservations:
            return ("My Reservations", "icon_reservation", "MyReservationsNavigation", true, 16.0)
        case .splitPayment:
            return ("Split The Bill Scanner", "icon_split_payment", "SplitTheBillNavigation", true, 16.0)
        case .notification:
            return ("Notifications", "icon_notification", "NotificationNavigation", true, 16.0)
        case .accountSettings:
            return ("Account Settings", "icon_account_settings", "AccountSettingsNavigation", true, 16.0)
        case .notificationSettings:
            return ("Notification Settings", "icon_notif_settings", "NotificationSettingsNavigation", true, 16.0)
        case .myAddresses:
            return ("My Addresses", "icon_my_addresses", "MyAddressesNavigation", true, 16.0)
        case .myCards:
            return ("My Cards", "icon_more_my_cards", "MyCardsNavigation", true, 16.0)
        case .preferences:
            return ("Preferences", "icon_preferences", "CategoryFilterNavigation", true, 16.0)
        case .reload:
            return ("Reload", "icon_reload", "ReloadNavigation", true, 16.0)
        case .faqs:
            return ("Frequently Asked Questions", "icon_faq", "FaqsNavigation", true, 16.0)
        case .rules:
            return ("Redemption & Reload Rules", "icon_rules", "RulesNavigation", true, 16.0)
        case .paymentSenseTermsAndConditions:
            return ("Paymentsense Terms", "paymentsense-icon", "PaymentSenseTermConditionsNavigation", true, 16.0)
        case .privacyPolicy:
            return ("Privacy Policy", "icon_privacy", "PrivacyNavigation", true, 16.0)
        case .signOut:
            return ("Sign Out", "icon_signout", "", false, 16.0)
        }
    }
    
    static func allMenuItems() -> [MenuItem] {
        return [
        MenuItem(type: .offerWallet),
        MenuItem(type: .splitPayment),
        MenuItem(type: .notification),
        MenuItem(type: .accountSettings),
        MenuItem(type: .myAddresses),
        MenuItem(type: .myCards),
        MenuItem(type: .notificationSettings),
        MenuItem(type: .preferences),
        MenuItem(type: .reload),
        MenuItem(type: .faqs),
        MenuItem(type: .rules),
        MenuItem(type: .paymentSenseTermsAndConditions),
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
