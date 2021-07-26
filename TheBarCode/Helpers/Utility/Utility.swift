//
//  Utility.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import KeychainAccess
import CoreStore
import GoogleMaps
import Firebase
import FirebaseDynamicLinks
import FirebaseCrashlytics
import OneSignal
import RNCryptor
import SquareInAppPaymentsSDK

let bundleId = Bundle.main.bundleIdentifier!
let androidPackageName = "com.milnesmayltd.thebarcode"

let theBarCodeInviteScheme = "theBarCodeInviteScheme"

let deviceIdKey = "deviceIdKey"

let kAppStoreId = "1441084506"

let genericErrorMessage = "Opps! Something went wrong"

let platform = "ios"
let appstoreUrlString = "itms-apps://itunes.apple.com/us/app/the-barcode-app/id1441084506?mt=8"

enum RedeemType: String {
    case standard = "standard",
    credit = "credit",
    any = "reload",
    unlimitedReload = "unlimited",
    voucher = "voucher"
}

enum NotificationType: String {
    case general = "admin",
    fiveADay = "five_a_day",
    liveOffer = "live_offer",
    shareOffer = "share_offer",
    chalkboard = "banner_ads",
    exclusive = "exclusive",
    event = "event",
    voucher = "voucher",
    order = "order",
    defaultNotification = "defaultNotification"
}

let notificationNameReloadSuccess: String = "notificationNameReloadSuccess"
let notificationNameDealRedeemed: String = "notificationNameDealRedeemed"
let notificationNameSharedOfferRedeemed: String = "notificationNameSharedOfferRedeemed"

let notificationNameFiveADayRefresh: String = "notificationNameFiveADayRefresh"
let notificationNameLiveOffer: String = "notificationNameLiveOffer"
let notificationNameAcceptSharedOffer: String = "notificationNameAcceptSharedOffer"

let notificationNameChalkboard = Notification.Name(rawValue: "notificationNameChalkboard")
let notificationNameExclusive = Notification.Name(rawValue: "notificationNameExclusive")
let notificationNameEvent = Notification.Name(rawValue: "notificationNameEvent")
let notificationNameRefreshExclusive = Notification.Name(rawValue: "notificationNameRefreshExclusive")

let notificationNameAcceptSharedEvent = Notification.Name("notificationNameAcceptSharedEvent")

let notificationNameBarDetailsRefreshed = Notification.Name(rawValue: "notificationNameBarDetailsRefreshed")

let notificationNameBookmarkAdded = Notification.Name(rawValue: "notificationNameBookmarkAdded")
let notificationNameBookmarkRemoved = Notification.Name(rawValue: "notificationNameBookmarkRemoved")

let notificationNameEventBookmarked = Notification.Name(rawValue: "notificationNameEventBookmarked")
let notificationNameBookmarkedEventRemoved = Notification.Name(rawValue: "notificationNameBookmarkedEventRemoved")

let notificationNameBarFavouriteAdded = Notification.Name(rawValue: "notificationNameBarFavouriteAdded")
let notificationNameBarFavouriteRemoved = Notification.Name(rawValue: "notificationNameBarFavouriteRemoved")

let notificationNameReloadAllSharedOffers = Notification.Name(rawValue: "notificationNameReloadAllSharedOffers")
let notificationNameReloadAllSharedEvents = Notification.Name(rawValue: "notificationNameReloadAllSharedEvents")

let notificationNameSharedOfferRemoved = Notification.Name(rawValue: "notificationNameSharedOfferRemoved")
let notificationNameSharedEventRemoved = Notification.Name(rawValue: "notificationNameSharedEventRemoved")

let notificationNameUnlimitedRedemptionPurchased = Notification.Name(rawValue: "notificationNameUnlimitedRedemptionPurchased")

let notificationNameVoucher = Notification.Name(rawValue: "notificationNameVoucher")
let notificationNameSearchVoucher = Notification.Name(rawValue: "notificationNameSearchVoucher")

let notificationNameRefreshNotifications = Notification.Name(rawValue: "notificationNameRefreshNotifications")
let notificationNameUpdateNotificationCount = Notification.Name(rawValue: "notificationNameUpdateNotificationCount")

let notificationNameProductCartUpdated = Notification.Name(rawValue: "notificationNameProductCartUpdated")
let notificationNameMyCartUpdated = Notification.Name(rawValue: "notificationNameMyCartUpdated")

let notificationNameOrderDidRefresh = Notification.Name(rawValue: "notificationNameOrderDidRefresh")
let notificationNameOrderPlaced = Notification.Name(rawValue: "notificationNameOrderPlaced")

let notificationNameOrderStatusUpdated = Notification.Name(rawValue: "notificationNameOrderStatusUpdated")
let notificationNameShowOrderDetails = Notification.Name(rawValue: "notificationNameShowOrderDetails")

typealias ProductCartUpdatedObject = (product: Product, newQuantity: Int, previousQuantity: Int, barId: String)
typealias OrderItemCartUpdatedObject = (itemId: String, newQuantity: Int, oldQuantity: Int, barId: String, controller: UIViewController)

let serverDateTimeFormat = "yyyy-MM-dd HH:mm:ss"
let serverTimeFormat = "HH:mm:ss"
let serverDateFormat = "yyyy-MM-dd"
let defaultUKLocation =  CLLocationCoordinate2D(latitude: 52.705674, longitude: -2.480438)

let dynamicLinkInviteDomain = "https://thebarcodeapp.page.link"
let dynamicLinkShareOfferDomain = "https://barcodeoffer.page.link"
let dynamicLinkGenaricDomain = "https://thebarcode.page.link"

let oneSignalStaggingAppId = "87a21c8e-cfee-4b79-8eef-23e692c64eca"
let oneSignalQAAppId = "5ce0f111-23bc-4aec-bc4e-b11bf065cfc8"
let oneSignalProdAppId = "a314acb3-b5df-442d-820e-6cfc6731fc70"

let squareUpAppIdSandbox = "sandbox-sq0idb-pb9LiBBq20hVo9pfOPaWKg"
let squareUpAppIdProd = "sq0idp-cTxLyYykw0EuzZ48xgUFRg"

let googleMapQAAppId = "AIzaSyCOY0CYfKs3TIAGdtrlqTl6tuJrzOOvDe4"
let googleMapProdAppId = "AIzaSyCOY0CYfKs3TIAGdtrlqTl6tuJrzOOvDe4"

let tbcLogoUrl = URL(string: "https://thebarcode.co/storage/tbc-logo.png")

let keyChainServiceName = bundleId + ".keychainservice"

let UKCountryCode = "UK"
let INCountryCode = "IN"

enum EnvironmentType: String {
    case dev = "dev", stagging = "stagging", qa = "qa", production = "production", unknown = "unknown"
    
    static func current() -> EnvironmentType {
        if theBarCodeAPIDomain == staggingAPIDomain || theBarCodeAPIDomain == barcodeStagingAPIDomain {
            return EnvironmentType.stagging
        } else if theBarCodeAPIDomain == qaAPIDomain {
            return EnvironmentType.qa
        } else if theBarCodeAPIDomain == productionAPIDomain {
            return EnvironmentType.production
        } else if theBarCodeAPIDomain == devAPIDomain {
            return EnvironmentType.dev
        } else {
            return EnvironmentType.unknown
        }
    }
}

class Utility: NSObject {
    
    private var encryptionPassword = "OvQzd7=m!7Hu^jeg"
    
    static let shared = Utility()
   
    var notificationCount: Int = 0
    
    var regionalInfo: (currencySymbol: String, reload: String, round: String, dialingCode: String, country: String) = (currencySymbol: "£", reload: "1", round: "20", dialingCode: "+44", country: "UK")

    static let barCodeDataStack = DataStack(
        CoreStoreSchema(
            modelVersion: "V1",
            entities: [
                Entity<Category>("Category"),
                Entity<FiveADayDeal>("FiveADayDeal"),
                Entity<Explore>("Explore", isAbstract: true),
                Entity<Bar>("Bar"),
                Entity<Deal>("Deal"),
                Entity<LiveOffer>("LiveOffer"),
                Entity<ImageItem>("ImageItem"),
                Entity<Offer>("Offer"),
                Entity<StandardOffer>("StandardOffer"),
                Entity<ActiveStandardOffer>("ActiveStandardOffer"),
                Entity<EstablishmentTiming>("EstablishmentTiming"),
                Entity<DeliveryTiming>("DeliveryTiming"),
                Entity<ExploreSchedule>("ExploreSchedule"),
                Entity<Event>("Event"),
                Entity<Product>("Product"),
                Entity<EventExternalCTA>("EventExternalCTA")
            ]
        )
    )
    
    lazy var deviceId: String = {
        
        let keychainService = Keychain(service: keyChainServiceName)
        func setDeviceIdInKeychain() -> String {
            let deviceId = UUID().uuidString
            do {
                try keychainService.set(deviceId, key: deviceIdKey)
            } catch {
                debugPrint("Unable to set the device id in keychain")
            }
            
            return deviceId
        }
        
        do {
            
            guard let deviceId = try keychainService.getString(deviceIdKey) else {
                debugPrint("Unable to get the device id from keychain")
                return setDeviceIdInKeychain()
            }
            
            return deviceId
        } catch {
            debugPrint("Unable to get the device id from keychain")
            return setDeviceIdInKeychain()
        }
        
    }()
    
    func saveRegionalInfoToUserDefaults() {
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(self.regionalInfo.currencySymbol, forKey: "currencySymbol")
        userDefaults.setValue(self.regionalInfo.reload, forKey: "reload")
        userDefaults.setValue(self.regionalInfo.round, forKey: "round")
        userDefaults.setValue(self.regionalInfo.country, forKey: "country")
        userDefaults.setValue(self.regionalInfo.dialingCode, forKey: "dialingCode")
        userDefaults.synchronize()
    }
    
    func restoreSavedRegionalInfoFromUserDefaults() {
        let userDefaults = UserDefaults.standard
        if let symbol = userDefaults.value(forKey: "currencySymbol") as? String,
           let reload = userDefaults.value(forKey: "reload") as? String,
           let round = userDefaults.value(forKey: "round") as? String,
           let country = userDefaults.value(forKey: "country") as? String,
           let dialingCode = userDefaults.value(forKey: "dialingCode") as? String {
            self.regionalInfo = (currencySymbol: symbol, reload: reload, round: round, dialingCode: dialingCode, country: country)
        }
    }
    
    func saveFullnameForAppleId(fullName: String) {
        let keychainService = Keychain(service: keyChainServiceName)
        try? keychainService.set(fullName, key: "appleIdFullName")
    }
    
    func getFullnameForAppleId() -> String? {
        let keychainService = Keychain(service: keyChainServiceName)
        
        do {
            guard let fullName = try keychainService.getString("appleIdFullName") else {
                return UserDefaults.standard.string(forKey: "appleIdFullName")
            }
            
            return fullName
        } catch {
            debugPrint("Unable to get the fullname from keychain")
            return nil
        }
    }
    
    func removeFullnameForAppleId() {
        let keychainService = Keychain(service: keyChainServiceName)
        UserDefaults.standard.removeObject(forKey: "appleIdFullName")
        try? keychainService.remove("appleIdFullName")
    }
    
    func saveCurrentUser(userDict: [String : Any]) -> User {
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            let user = try! transaction.importUniqueObject(Into<User>(), source: userDict)
            let _ = try! transaction.deleteAll(From<User>().where(\User.userId != user!.userId.value))
        })
        return self.getCurrentUser()!
    }
    
    func getCurrentUser() -> User? {
        let user = try! CoreStore.fetchOne(From<User>())
        return user
    }
    
    func removeUser() {
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            try! transaction.deleteAll(From<User>())
        })
        APIHelper.shared.setUpOAuthHandler(accessToken: nil, refreshToken: nil)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.stopVisitLocationManager()
        
        Crashlytics.crashlytics().setUserID("")
        
        debugPrint("cleared user info from local db")
    }
    
    func serverDateFormattedString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        return dateFormatter.string(from: date)
    }
    
    func serverFormattedTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverTimeFormat
        return dateFormatter.string(from: date)
    }
    
    func serverFormattedDateTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateTimeFormat
        return dateFormatter.string(from: date)
    }
    
    func shortFormattedDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd  hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    func serverFormattedDateTime(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateTimeFormat
        dateFormatter.timeZone = serverTimeZone
        return dateFormatter.date(from: date)!
    }
    
    func serverFormattedTime(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverTimeFormat
        dateFormatter.timeZone = serverTimeZone
        return dateFormatter.date(from: date)!
    }
    
    func serverFormattedDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        dateFormatter.timeZone = serverTimeZone
        return dateFormatter.date(from: date)!
    }
    
    func shortFormattedDate(date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd  hh:mm a"
        dateFormatter.timeZone = serverTimeZone
        return dateFormatter.date(from: date)!
    }
    
    func getformattedDistance(distance: Double) -> String {
        let formattedDistance = distance == 0 ? "0" : String(format: "%.2f", distance)
        return String(format: "%@ mile%@ away", formattedDistance, (distance > 1 ? "s" : ""))
    }

    //decrement credit by 1 
    func userCreditConsumed() {
        let user = try! CoreStore.fetchOne(From<User>())
        
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            let editedObject = transaction.edit(user)
            if let creditInt = Int(editedObject!.creditsRaw.value!), creditInt > 0 {
                let credit = creditInt - 1
                editedObject!.creditsRaw.value = "\(credit)"
            }
        })
        
        debugPrint("User Credit Consumed in local db")
    }
    
    func userCreditUpdate(creditValue: Int) {
        let user = try! CoreStore.fetchOne(From<User>())
        
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            let editedObject = transaction.edit(user)
            editedObject?.creditsRaw.value = "\(creditValue)"
        })
        
        debugPrint("User Credit Update in local db")

    }
    
    func updateDefaultDeliveryNumber(mobileNumber: String) {
        let user = try! CoreStore.fetchOne(From<User>())
        
        try! CoreStore.perform(synchronous: { (transaction) -> Void in
            let editedObject = transaction.edit(user)
            editedObject?.deliveryMobileNumber.value = mobileNumber
        })
        
        debugPrint("User delivery mobile number updated in local db")
    }
    
    func getFormattedRemainingTime(time: TimeInterval) -> String {
        
        let timeInt = Int(time)
        
        let days = Int(timeInt / 86400)
        let hours = Int((timeInt % 86400) / 3600)
        let minutes = Int((timeInt % 3600) / 60)
        let seconds = Int((timeInt % 3600) % 60)
        
        return String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
    }
    
    func getFormattedRemainingTimeInHours(time: TimeInterval) -> String {
        
        let timeInt = Int(time)
        
        let hours = Int((timeInt % 86400) / 3600)
        let minutes = Int((timeInt % 3600) / 60)
        let seconds = Int((timeInt % 3600) % 60)
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func checkDealType(offerTypeID: String) -> OfferType {
        switch offerTypeID {
        case "1":
            return OfferType.live
        case "2":
            return OfferType.fiveADay
        case "3":
            return OfferType.exclusive
        case "4":
            return OfferType.bannerAds
        case "5":
            return OfferType.standard
        default:
            return OfferType.unknown
        }
    }
    
    func getReferralCodeFromUrlString(urlString: String) -> String? {
        
        var referralCode: String?
        
        let urlComponents = URLComponents(string: urlString)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "referral" {
                    referralCode = queryItem.value
                    break
                }
            }
        }
        
        return referralCode
    }
    
    func getInfluencerIdFromUrlString(urlString: String) -> String? {
        
        var influencerId: String?
        
        let urlComponents = URLComponents(string: urlString)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "influencer_id" {
                    influencerId = queryItem.value
                    break
                }
            }
        }
        
        return influencerId
    }
    
    func getSharedOfferParams(urlString: String) -> SharedOfferParams? {
        
        var referral: String?
        var offerId: String?
        var sharedBy: String?
        var sharedByName: String?

        let urlComponents = URLComponents(string: urlString)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "referral" {
                    referral = queryItem.value
                } else if queryItem.name == "offer_id" {
                    offerId = queryItem.value
                } else if queryItem.name == "shared_by" {
                    sharedBy = queryItem.value
                } else if queryItem.name == "shared_by_name" {
                    sharedByName = queryItem.value
                }
            }
        }
        
        if let referral = referral, let offerId = offerId, let sharedBy = sharedBy, let sharedByName = sharedByName {
            let sharedOfferParams = SharedOfferParams(referral: referral, sharedBy: sharedBy, offerId: offerId, sharedByName: sharedByName)
            return sharedOfferParams
        } else {
            return nil
        }
        
    }
    
    func getSharedEventParams(urlString: String) -> SharedEventParams? {
        var referral: String?
        var eventId: String?
        var sharedBy: String?
        var sharedByName: String?
        
        let urlComponents = URLComponents(string: urlString)
        if let queryItems = urlComponents?.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "referral" {
                    referral = queryItem.value
                } else if queryItem.name == "event_id" {
                    eventId = queryItem.value
                } else if queryItem.name == "shared_by" {
                    sharedBy = queryItem.value
                } else if queryItem.name == "shared_by_name" {
                    sharedByName = queryItem.value
                }
            }
        }
        
        if let referral = referral, let eventId = eventId, let sharedBy = sharedBy, let sharedByName = sharedByName {
            let sharedEventParams = SharedEventParams(referral: referral, sharedBy: sharedBy, eventId: eventId, sharedByName: sharedByName)
            return sharedEventParams
        } else {
            return nil
        }
        
    }
    
    func generateAndShareDynamicLink(deal: Deal, controller: UIViewController, presentationCompletion: @escaping (() -> Void), dismissCompletion: @escaping (() -> Void) ) {
        
        let user = Utility.shared.getCurrentUser()!
        let ownReferralCode = user.ownReferralCode.value
        let offerShareUrlString = theBarCodeAPIDomain + "?referral=" + ownReferralCode + "&offer_id=" + deal.id.value + "&shared_by=" + user.userId.value + "&shared_by_name=" + user.fullName.value
        
        let url = URL(string: offerShareUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let iOSNavigationParams = DynamicLinkNavigationInfoParameters()
        iOSNavigationParams.isForcedRedirectEnabled = false
        
        let linkComponents = DynamicLinkComponents(link: url, domainURIPrefix: dynamicLinkShareOfferDomain)!
        linkComponents.navigationInfoParameters = iOSNavigationParams
        linkComponents.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkComponents.iOSParameters?.appStoreID = kAppStoreId
        linkComponents.iOSParameters?.customScheme = theBarCodeInviteScheme
        
        linkComponents.androidParameters = DynamicLinkAndroidParameters(packageName: androidPackageName)
        
        let descText = "\(user.fullName.value) has shared an offer with you, check it out! Pass on great offers AND get credits when your friends redeem them, so why not share the love."
        linkComponents.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkComponents.socialMetaTagParameters?.title = "The Barcode"
        linkComponents.socialMetaTagParameters?.descriptionText = descText
        linkComponents.socialMetaTagParameters?.imageURL = tbcLogoUrl
        
        linkComponents.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkComponents.otherPlatformParameters?.fallbackUrl = URL(string: barCodeDomainURLString)
        
        linkComponents.shorten { (shortUrl, warnings, error) in
            
            guard error == nil else {
                presentationCompletion()
                controller.showAlertController(title: "Invite", msg: error!.localizedDescription)
                return
            }
            
            if let warnings = warnings {
                debugPrint("Dynamic link generation warnings: \(String(describing: warnings))")
            }
            
            let activityViewController = UIActivityViewController(activityItems: [descText, shortUrl!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = controller.view
            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                dismissCompletion()
            }
            controller.present(activityViewController, animated: true, completion: {
                presentationCompletion()
            })
        }
        
    }
    
    func generateAndShareDynamicLink(event: Event, controller: UIViewController, presentationCompletion: @escaping (() -> Void), dismissCompletion: @escaping (() -> Void) ) {
        
        let user = Utility.shared.getCurrentUser()!
        let ownReferralCode = user.ownReferralCode.value
        let offerShareUrlString = theBarCodeAPIDomain + "?referral=" + ownReferralCode + "&event_id=" + event.id.value + "&shared_by=" + user.userId.value + "&shared_by_name=" + user.fullName.value
        
        let url = URL(string: offerShareUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let iOSNavigationParams = DynamicLinkNavigationInfoParameters()
        iOSNavigationParams.isForcedRedirectEnabled = false
        
        let linkComponents = DynamicLinkComponents(link: url, domainURIPrefix: dynamicLinkGenaricDomain)!
        linkComponents.navigationInfoParameters = iOSNavigationParams
        linkComponents.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkComponents.iOSParameters?.appStoreID = kAppStoreId
        linkComponents.iOSParameters?.customScheme = theBarCodeInviteScheme
        
        linkComponents.androidParameters = DynamicLinkAndroidParameters(packageName: androidPackageName)
        
        let descText = "\(user.fullName.value) has shared an event with you, check it out!"
        linkComponents.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkComponents.socialMetaTagParameters?.title = "The Barcode"
        linkComponents.socialMetaTagParameters?.descriptionText = descText
        linkComponents.socialMetaTagParameters?.imageURL = tbcLogoUrl
        
        linkComponents.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkComponents.otherPlatformParameters?.fallbackUrl = URL(string: barCodeDomainURLString)
        
        linkComponents.shorten { (shortUrl, warnings, error) in
            
            guard error == nil else {
                presentationCompletion()
                controller.showAlertController(title: "Share Event", msg: error!.localizedDescription)
                return
            }
            
            if let warnings = warnings {
                debugPrint("Dynamic link generation warnings: \(String(describing: warnings))")
            }
            
            let activityViewController = UIActivityViewController(activityItems: [descText, shortUrl!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = controller.view
            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                dismissCompletion()
            }
            controller.present(activityViewController, animated: true, completion: {
                presentationCompletion()
            })
        }
        
    }
    
    func oneSignalAppId() -> String {
        let currentEnvironment = EnvironmentType.current()
        if currentEnvironment == .stagging {
            return oneSignalStaggingAppId
        } else if currentEnvironment == .qa || currentEnvironment == .dev {
            return oneSignalQAAppId
        } else if currentEnvironment == .production {
            return oneSignalProdAppId
        } else {
            return ""
        }
    }
    
    func squareUpAppId() -> String {
        let currentEnvironment = EnvironmentType.current()
        if currentEnvironment == .production {
            return squareUpAppIdProd
        } else {
            return squareUpAppIdSandbox
        }
    }
    
    func getPinImage(offerType: StandardOfferType) -> UIImage {
        switch offerType {
        case .bronze:
            return UIImage(named: "icon_pin_bronze")!
        case .silver:
            return UIImage(named: "icon_pin_silver")!
        case .gold:
            return UIImage(named: "icon_pin_gold")!
        case .platinum:
            return UIImage(named: "icon_pin_platinum")!
        default:
            return UIImage(named: "icon_pin_gold")!
        }
    }
    
    func getRibbonColors(offerType: StandardOfferType) -> (startColor: UIColor, endColor:UIColor) {
        switch offerType {
        case .bronze:
            return UIColor.appBronzeColors()
            
        case .silver:
            return UIColor.appSilverColors()
            
        case .gold:
            return UIColor.appGoldColors()
            
        case .platinum:
            return UIColor.appPlatinumColors()
            
        default:
            return UIColor.appDefaultColors()
        }
    }
    
    func getDefaultRibbonColors() -> (startColor: UIColor, endColor:UIColor) {
        return UIColor.appDefaultColors()
    }
    
    func getMapBarPinImage(mapBar: MapBasicBar) -> UIImage {
        
        var pinImage = UIImage(named: "icon_pin_grayed")!
        if mapBar.isOpen {
            if mapBar.currentlyUnlimitedRedemptionAllowed {
                pinImage = UIImage(named: "icon_pin_platinum")!
            } else {
                pinImage = Utility.shared.getPinImage(offerType: mapBar.standardOfferType)
            }
        }
        
        return pinImage
    }
    
    func logout() {
        OneSignal.deleteTag("user_id")
        Utility.shared.removeUser()
    }
    
    static func popToSignIn() {

        DispatchQueue.main.async {
            
            Utility.shared.logout()
            APIHelper.shared.setUpOAuthHandler(accessToken: nil, refreshToken: nil)
            
            if let topController = UIApplication.topViewController() {
                
                if let tabBarVC = topController.tabBarController {
                    tabBarVC.dismiss(animated: true, completion: nil)
                } else {
                    if topController.isMember(of: SplashViewController.self) {
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let splashController = (storyboard.instantiateViewController(withIdentifier: "SplashViewController") as! SplashViewController)
                        topController.navigationController?.setViewControllers([splashController], animated: false)
                    } else {
                        Utility.dismissTopController()
                    }
                }
            } else {
                debugPrint("no topController ")
            }
        }
    }
    
   static func dismissTopController() {
        let topController = UIApplication.topViewController()!
        topController.dismiss(animated: false, completion: {
                              
            let topController = UIApplication.topViewController()!
            if let tabBarVC = topController.tabBarController {
                tabBarVC.dismiss(animated: true, completion: nil)
            } else {
                self.dismissTopController()
            }
        })
    }
    
    func getDeliveryCharges(order: Order, totalPrice: Double) -> Double {
        if order.isGlobalDeliveryAllowed == true {
            return order.globalDeliveryCharges ?? 0.0
        } else {
            if let customDeliveryCharges = order.customDeliveryCharges, totalPrice >= customDeliveryCharges {
                return order.minDeliveryCharges ?? 0.0
            } else {
                return order.maxDeliveryCharges ?? 0.0
            }
        }
    }
}

extension Utility {
    func encrypt(data: [String : Any]) -> String? {
        
        do {
//            let jsonData = "{\"card_number\":\"4444333322221111\",\"cvc\":\"123\",\"expiry_month\":\"12\",\"expiry_year\":\"2021\",\"name\":\"Abdul Rehman\"}".data(using: .utf8)!
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .fragmentsAllowed)
//            let base64Data = jsonData.base64EncodedData()
            let encryptedData = RNCryptor.encrypt(data: jsonData, withPassword: encryptionPassword)
            let encryptedString = encryptedData.base64EncodedString()
            
            return encryptedString
            
        } catch {
            debugPrint("Error while encryption: \(error.localizedDescription)")
        }
        
        return nil
        
    }
    
    func decrypt(encryptedString: String) -> [String : Any]? {
        
        do {
            let encryptedData = Data(base64Encoded: encryptedString)!
            let originalData = try RNCryptor.decrypt(data: encryptedData, withPassword: encryptionPassword)
//            let jsonStringData = Data(base64Encoded: originalData)!
            let jsonDict = try! JSONSerialization.jsonObject(with: originalData, options: .allowFragments) as! [String : Any]
            
            return jsonDict
        } catch {
            debugPrint("Error while decryption: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func plainToCipher(string: String) -> String {
        let base64Data = string.data(using: .utf8)!.base64EncodedData()
        let encryptedData = RNCryptor.encrypt(data: base64Data, withPassword: encryptionPassword)
        
        let encryptedString = encryptedData.base64EncodedString()
        
        return encryptedString
    }
    
    func cipherToPlain(string: String) -> String {
        let encryptedData = Data(base64Encoded: string)!
        let originalData = try! RNCryptor.decrypt(data: encryptedData, withPassword: encryptionPassword)
        let dataRaw = Data(base64Encoded: originalData)!
        
        return String(data: dataRaw, encoding: .utf8)!
    }
    
    func makeSquareTheme() -> SQIPTheme {
        let theme = SQIPTheme()
        theme.errorColor = .red
        theme.foregroundColor = UIColor.appBgGrayColor()
        theme.tintColor = UIColor.appBlueColor()
        theme.keyboardAppearance = .dark
        theme.messageColor = UIColor.white
        theme.font = UIFont.appRegularFontOf(size: 16.0)
        theme.backgroundColor = UIColor.appCartUnSelectedColor()
        theme.textColor = UIColor.white
        theme.saveButtonFont = UIFont.appBoldFontOf(size: 16.0)
        theme.saveButtonTextColor = UIColor.white
        theme.saveButtonTitle = "Proceed"
        
        return theme
    }
}

//MARK: Update Cart
extension Utility {
    func updateCart(product: Product, shouldAdd: Bool, barId: String, shouldSeperateCards: Bool, cart_type: String, completion: @escaping (_ error: NSError?) -> Void, successCompletion: @escaping (_ type: String) -> Void, updateCountCompletion: @escaping (_ cartItemID: String) -> Void) {
        
        var params: [String : Any] = ["id" : product.id.value,
                                      "establishment_id" : barId]
        if let cartItemId = product.cartItemId.value {
            params["cart_item_id"] = cartItemId
        }
        
        if shouldAdd {
            product.isAddingToCart = true
            params["quantity"] = product.quantity.value + 1
        } else {
            product.isRemovingFromCart = true
            params["quantity"] = 0
        }
        
        if shouldSeperateCards {
            params["cart_type"] = cart_type
        }
        
        successCompletion(cart_type)
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            var cartItemId: String? = nil
            defer {
                updateCountCompletion(cartItemId ?? "")
            }
            
            guard error == nil else {
                completion(error as NSError?)
                return
            }
            
            guard serverError == nil else {
                if serverError!.detail.count > 0 {
                    let nsError = NSError(domain: "ServerError", code: serverError!.statusCode, userInfo: [NSLocalizedDescriptionKey : serverError!.detail])
                    completion(nsError)
                } else {
                    completion(serverError!.nsError())
                }
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [String : Any],
                let items = data["menuItems"] as? [[String : Any]],
                let item = items.first(where: { "\($0["id"]!)" == product.id.value }),
                let _ = item["cart_item_id"]  {
                
                cartItemId = "\(item["cart_item_id"]!)"
            }
        }
    }
}
