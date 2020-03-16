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
    unlimitedReload = "unlimited"
}

enum NotificationType: String {
    case general = "admin",
    fiveADay = "five_a_day",
    liveOffer = "live_offer",
    shareOffer = "share_offer",
    chalkboard = "banner_ads",
    exclusive = "exclusive",
    event = "event"
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


let googleMapQAAppId = "AIzaSyCOY0CYfKs3TIAGdtrlqTl6tuJrzOOvDe4"
let googleMapProdAppId = "AIzaSyCOY0CYfKs3TIAGdtrlqTl6tuJrzOOvDe4"

let tbcLogoUrl = URL(string: "https://thebarcode.co/storage/tbc-logo.png")

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
    
    static let shared = Utility()
    
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
                Entity<ExploreSchedule>("ExploreSchedule"),
                Entity<Event>("Event"),
                Entity<Food>("Food"),
                Entity<Drink>("Drink"),
                Entity<EventExternalCTA>("EventExternalCTA")
            ]
        )
    )
    
    lazy var deviceId: String = {
        
        let keyChainServiceName = bundleId + ".keychainservice"
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
}
