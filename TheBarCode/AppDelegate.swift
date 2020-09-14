//
//  AppDelegate.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import GoogleMaps
import FBSDKLoginKit
import Firebase
import FirebaseDynamicLinks
import FirebaseCrashlytics
import OneSignal
import CoreStore
import CoreLocation
import BugfenderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var referralCode: String?
    var sharedOfferParams: SharedOfferParams?
    var sharedEventParams: SharedEventParams?
    
    var liveOfferBarId: String?
    var chalkboardBarId: String?
    var exclusiveBarId: String?
    var eventBarId: String?
    var voucherTitle: String?
    var orderId: String?

    var refreshFiveADay: Bool?
    
    var visitLocationManager: CLLocationManager?
    
    var locationManager: MyLocationManager!
    
    var isSyncingInfluencer: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let v1Schema = CoreStoreSchema(
            modelVersion: "V3",
            entities: [
                Entity<V1.User>("User")
            ]
        )
    
        let schemaHistory = SchemaHistory(allSchema: [v1Schema], migrationChain: ["V3"])
        
        let persistantDataStack = DataStack(schemaHistory: schemaHistory)
        CoreStore.defaultStack = persistantDataStack
        
        let localStorage = SQLiteStore(fileName: "TheBarCode.sqlite", localStorageOptions: .recreateStoreOnModelMismatch)
        try! CoreStore.addStorageAndWait(localStorage)
        
        let dataStorage = SQLiteStore(fileName: "TheBarCode_Data.sqlite", localStorageOptions: .allowSynchronousLightweightMigration)
        if FileManager.default.fileExists(atPath: dataStorage.fileURL.path) {
            do {
                try FileManager.default.removeItem(at: dataStorage.fileURL)
            } catch {
                debugPrint("Error while deleting mismatched model version: \(error.localizedDescription)")
            }
        }
        
        let dataStack = Utility.barCodeDataStack
        try! dataStack.addStorageAndWait(dataStorage)
        
        self.setupAuthIfNeeded()
        
        self.customizeAppearance()
        GMSServices.provideAPIKey(googleMapProdAppId)
        
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = theBarCodeInviteScheme
        FirebaseApp.configure()
        
        Crashlytics.crashlytics().setCustomValue(EnvironmentType.current().rawValue, forKey: "ENV")
        
        Bugfender.activateLogger("WD6RXFEeYgdRgCrl5bdRVwaBTbbICqAq")
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            debugPrint("push message = \(String(describing: payload!.body))")
            debugPrint("push badge number = \(payload?.badge ?? 0)")
            debugPrint("push notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData, let notificationTypeRaw: String = additionalData["type"] as? String, let notificationType = NotificationType(rawValue: notificationTypeRaw) {
                debugPrint("additionalData = \(additionalData)")

                if notificationType == NotificationType.event, let barDict = additionalData["bar"] as? [String : Any] {
                    
                    let barId = "\(barDict["id"]!)"
                    self.eventBarId = barId
                    NotificationCenter.default.post(name: notificationNameEvent, object: nil)
                    
                } else if notificationType == NotificationType.exclusive, let barDict = additionalData["bar"] as? [String : Any] {
                    
                    let barId = "\(barDict["id"]!)"
                    self.exclusiveBarId = barId
                    NotificationCenter.default.post(name: notificationNameExclusive, object: nil)
                    
                } else if notificationType == NotificationType.chalkboard, let barDict = additionalData["bar"] as? [String : Any] {
                    
                    let barId = "\(barDict["id"]!)"
                    self.chalkboardBarId = barId
                    NotificationCenter.default.post(name: notificationNameChalkboard, object: nil)
                    
                } else if notificationType == NotificationType.liveOffer, let barDict = additionalData["bar"] as? [String : Any] {
                    
//                    let barId = "\(barDict["id"]!)"
//                    self.liveOfferBarId = barId
//                    
//                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameLiveOffer), object: nil)
                } else if notificationType == NotificationType.fiveADay {
                    self.refreshFiveADay = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
                } else if notificationType == NotificationType.shareOffer {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
                    
                } else if notificationType == NotificationType.voucher, let offerDict = additionalData["offer"] as? [String: Any] {
                    
                    let title = "\(offerDict["title"]!)"
                    self.voucherTitle = title
                    NotificationCenter.default.post(name: notificationNameVoucher, object: nil)
                
                } else if notificationType == NotificationType.order, let orderId = (additionalData["order"] as? [String : Any])?["id"] {
                    
                    self.orderId = "\(orderId)"
                    NotificationCenter.default.post(name: notificationNameShowOrderDetails, object: self.orderId!)
                    
                } else {
                    
                }
            }
        }
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            debugPrint("Received Notification")
            //Inc Notification Count
            Utility.shared.notificationCount = Utility.shared.notificationCount + 1
            NotificationCenter.default.post(name: notificationNameUpdateNotificationCount, object: nil)
            //Auto fresh notification List
            NotificationCenter.default.post(name: notificationNameRefreshNotifications, object: nil)
            
            if let additionalData = notification?.payload.additionalData,
                let typeRaw = additionalData["type"] as? String,
                let type = NotificationType(rawValue: typeRaw),
                let orderInfo = additionalData["order"] as? [String : Any],
                let orderId = orderInfo["id"],
                type == .order {
                NotificationCenter.default.post(name: notificationNameOrderStatusUpdated, object: "\(orderId)")
            }
            
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.setRequiresUserPrivacyConsent(false)
        OneSignal.inFocusDisplayType = .notification
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Utility.shared.oneSignalAppId(),
                                        handleNotificationReceived: notificationReceivedBlock,
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        self.startVisitLocationManager()
        
        if let userActivityDictionary = launchOptions?[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [String : Any] {
            if let userActivity = userActivityDictionary["UIApplicationLaunchOptionsUserActivityKey"] as? NSUserActivity {
                print("activityDictionary: \(String(describing: userActivity))")
            }
        }
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        Analytics.logEvent(appLaunched, parameters: nil)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        self.updateLocationComingFromBackground()
        self.getUnreadNotificationCountComingFromBackground()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        Thread.sleep(forTimeInterval: 0.2)
        
        let handled = self.handleUserActivity(userActivity: userActivity)
        return handled
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "fb182951649264383" {
            let handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options)
            return handled ?? false
        } else if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url), let link = dynamicLink.url {
            
            if let sharedOfferParams = Utility.shared.getSharedOfferParams(urlString: link.absoluteString) {
                self.sharedOfferParams = sharedOfferParams
                self.referralCode = sharedOfferParams.referral!
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
            } else if let sharedEventParams = Utility.shared.getSharedEventParams(urlString: link.absoluteString) {
                self.sharedEventParams = sharedEventParams
                self.referralCode = sharedEventParams.referral
                NotificationCenter.default.post(name: notificationNameAcceptSharedEvent, object: nil)
            } else if let code = Utility.shared.getReferralCodeFromUrlString(urlString: link.absoluteString) {
                self.referralCode = code
            } else if let influencerId = Utility.shared.getInfluencerIdFromUrlString(urlString: link.absoluteString) {
                
                UserDefaults.standard.setValue(influencerId, forKey: "influencerId")
                UserDefaults.standard.synchronize()
                
                self.syncInfluencerInstallation(influencerId: influencerId)
            } else {
                debugPrint("Unable to parse referral code url: ")
            }
            
            return true
        } else if url.scheme?.lowercased() == theBarCodeInviteScheme.lowercased() {
            if let code = Utility.shared.getReferralCodeFromUrlString(urlString: url.absoluteString) {
                self.referralCode = code
            } else {
                debugPrint("Unable to parse referral code url scheme: ")
            }
            return true
        }
        
        return false
        
    }
    
    func handleUserActivity(userActivity: NSUserActivity) -> Bool {
        
        guard let universalUrl = userActivity.webpageURL else {
            debugPrint("Universal url is nil")
            
            let error = NSError(domain: "DynamicLinkNotFound", code: -1001, userInfo: [NSLocalizedDescriptionKey : "User activity webpage url property is nil"])
            Crashlytics.crashlytics().record(error: error)
            
            return false
        }
        
        
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(universalUrl) { (dynamicLink, error) in
            
            guard error == nil else {
                debugPrint("Error while getting dynamic link: \(error!.localizedDescription)")
                return
            }
            
            if universalUrl.host == URL(string: dynamicLinkInviteDomain)!.host {
                if let code = Utility.shared.getReferralCodeFromUrlString(urlString: dynamicLink!.url!.absoluteString) {
                    self.referralCode = code
                } else {
                    debugPrint("Unable to parse referral code: ")
                }
                
            } else if universalUrl.host == URL(string: dynamicLinkShareOfferDomain)!.host {
                if let sharedOfferParams = Utility.shared.getSharedOfferParams(urlString: dynamicLink!.url!.absoluteString) {
                    self.sharedOfferParams = sharedOfferParams
                    self.referralCode = sharedOfferParams.referral!
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
                } else {
                    debugPrint("Unable to parse shared offer params: ")
                }
            } else if universalUrl.host == URL(string: dynamicLinkGenaricDomain)!.host {
                if let sharedEventParams = Utility.shared.getSharedEventParams(urlString: dynamicLink!.url!.absoluteString) {
                    self.sharedEventParams = sharedEventParams
                    self.referralCode = sharedEventParams.referral
                    NotificationCenter.default.post(name: notificationNameAcceptSharedEvent, object: nil)
                } else {
                    debugPrint("shared offer/event params unavailable")
                }
            } else {
                debugPrint("Unhandled dynamic link domain")
            }
        }
        
        return handled
    }
    
    func setupAuthIfNeeded() {
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User not found for auth setup")
            return
        }
        
        APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
    }
    
    func startVisitLocationManager() {
        guard let _ = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists to subscribe to location updates")
            return
        }
        
        guard CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse else {
            debugPrint("location permission not granted")
            return
        }
        
        self.stopVisitLocationManager()
        
        self.visitLocationManager = CLLocationManager()
        self.visitLocationManager?.startMonitoringVisits()
        self.visitLocationManager?.delegate = self
        
        debugPrint("Starting visit location manager")
    }
    
    func stopVisitLocationManager() {
        self.visitLocationManager?.stopMonitoringVisits()
        self.visitLocationManager = nil
        
        debugPrint("Stopping visit location manager")
    }
}

//MARK: CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        debugPrint("Will update visit to server:")
        self.updateVisit(visit: visit)
    }
    
    func newVisitReceived(_ visit: CLVisit, description: String) {
        return;
        let content = UNMutableNotificationContent()
        content.title = "New BarCode entry 📌📌📌"
        content.body = description
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
}

//Webservices Methods
extension AppDelegate {
    func updateVisit(visit: CLVisit) {
        guard let _ = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists for location update")
            self.newVisitReceived(visit, description: "User does not exists")
            return
        }
        
        self.newVisitReceived(visit, description: "Updating location on server")
        
        let params = ["latitude" : "\(visit.coordinate.latitude)",
            "longitude" : "\(visit.coordinate.longitude )"] as [String : Any]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while updating location: \(error!.localizedDescription)")
                self.newVisitReceived(visit, description: "Location update failed: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while updating location: \(serverError!.errorMessages())")
                self.newVisitReceived(visit, description: "Location update failed: \(serverError!.errorMessages())")
                return
            }
            
            debugPrint("Visit location updated successfully")
            self.newVisitReceived(visit, description: "Location update success")
        })
    }
    
    func syncInfluencerInstallation(influencerId: String) {
        
        guard !self.isSyncingInfluencer else {
            debugPrint("Already syncing influencer")
            return
        }
        
        self.isSyncingInfluencer = true
        
        let params = ["influencer_id" : influencerId,
                      "platform" : platform,
                      "device_id" : Utility.shared.deviceId]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathInfluencer, method: .post) { (response, serverError, error) in
            
            self.isSyncingInfluencer = false
            
            guard error == nil else {
                debugPrint("Error while syncing influencer result: \(error!.localizedDescription)")
                return
            }
            
            UserDefaults.standard.removeObject(forKey: "influencerId")
            UserDefaults.standard.synchronize()
            
            guard serverError == nil else {
                debugPrint("Server error while syncing influencer result: \(serverError!.messages)")
                return
            }
            
            
            
            debugPrint("Synced successfully")
        }
    }
}

//MARK: Appearance Customization
extension AppDelegate {
    func customizeAppearance() {
        
        let navigationBar = UINavigationBar.appearance()
        
        let scale = UIScreen.main.scale
        
        var navigationBarSize = navigationBar.frame.size
        navigationBarSize.width = UIScreen.main.bounds.size.width * scale
        navigationBarSize.height = 64.0 * scale
        
        let image = UIImage.from(color: UIColor.appNavBarGrayColor(), size: navigationBarSize)
        navigationBar.setBackgroundImage(image, for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.tintColor = UIColor.appBlueColor()
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font : UIFont.appBoldFontOf(size: 16.0), NSAttributedStringKey.foregroundColor : UIColor.white]
        
        navigationBar.isTranslucent = true
        
        let barButtonItem = UIBarButtonItem.appearance()
        barButtonItem.tintColor = UIColor.appBlueColor()
        
        let tabbar = UITabBar.appearance()
        tabbar.backgroundColor = UIColor.appNavBarGrayColor()
        tabbar.tintColor = UIColor.appBlueColor()
        tabbar.unselectedItemTintColor = UIColor.appGrayColor()
        tabbar.shadowImage = UIImage()
        
        let searchBar = UISearchBar.appearance()
        searchBar.tintColor = UIColor.white
        
        let searchBarTextField = UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self, SearchViewController.self])
        searchBarTextField.tintColor = UIColor.white
        searchBarTextField.font = UIFont.appRegularFontOf(size: 14.0)
        
        UILabel.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.appRegularFontOf(size: 14.0)
        UIPickerView.appearance(whenContainedInInstancesOf: [UIView.self]).backgroundColor = UIColor.clear
        
        let segmentedControl = UISegmentedControl.appearance()
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = UIColor.appBlueColor()
            segmentedControl.backgroundColor = UIColor.appDarkGrayColor()
        }
        
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                                 NSAttributedStringKey.foregroundColor : UIColor.white], for: .normal)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                                 NSAttributedStringKey.foregroundColor : UIColor.black], for: .selected)
        
        UIRefreshControl.appearance().tintColor = UIColor.white
        UIActivityIndicatorView.appearance().tintColor = UIColor.white
        
        let alertView = UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self])
        if #available(iOS 13.0, *) {
            alertView.tintColor = UIColor.appBlueColor()
            alertView.overrideUserInterfaceStyle = .dark
        }
        
        let tableView = UITableView.appearance()
        tableView.separatorColor = UIColor.lightGray
    }
}

extension AppDelegate {
    
    func updateLocationComingFromBackground() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists for location update")
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        var canContinue: Bool? = nil
        if authorizationStatus == .authorizedAlways {
            canContinue = true
        } else if authorizationStatus == .authorizedWhenInUse {
            canContinue = false
        }
        
        guard let requestAlwaysAccess = canContinue else {
            debugPrint("Location permission not authorized")
            return
        }
        
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyBestForNavigation, timeOut: 20.0) { (location, error) in
            
            guard error == nil else {
                debugPrint("Error while getting location: \(error!.localizedDescription)")
                return
            }
            
            var params = ["latitude" : "\(location!.coordinate.latitude)",
                "longitude" : "\(location!.coordinate.longitude )"] as [String : Any]
            
            try! CoreStore.perform(synchronous: { (transaction) -> Void in
                let edittedUser = transaction.edit(user)
                edittedUser?.latitude.value = location!.coordinate.latitude
                edittedUser?.longitude.value = location!.coordinate.longitude
                
            })
            
            if !Utility.shared.getCurrentUser()!.isLocationUpdated.value {
                params["send_five_day_notification"] = true
            }
            
            let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
                
                guard error == nil else {
                    debugPrint("Error while updating location: \(error!.localizedDescription)")
                    return
                }
                
                guard serverError == nil else {
                    debugPrint("Server error while updating location: \(serverError!.errorMessages())")
                    return
                }
                
                debugPrint("Location update successfully")
                
                let responseDict = response as? [String : Any]
                if let responseData = (responseDict?["data"] as? [String : Any])
                {
                    if let creditValue = responseData["credit"] as? Int {
                        debugPrint("credit == \(creditValue)")
                        Utility.shared.userCreditUpdate(creditValue: creditValue)
                    }
                    
                }
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let edittedUser = transaction.edit(user)
                    edittedUser?.isLocationUpdated.value = true
                })
                
            })
        }
    }
    
    func getUnreadNotificationCountComingFromBackground() {
       
        guard let _ = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists for getting UnreadNotificationCount")
            return
        }
        
        let params: [String : Any] = [:]
           
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathNotificationCount, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting UnreadNotificationCount: \(error!.localizedDescription)")
                return
            }
               
            guard serverError == nil else {
                debugPrint("Error while getting UnreadNotificationCount: \(error!.localizedDescription)")
                return
            }
            
            debugPrint("UnreadNotificationCount get successfully")

               
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let dataDict = (responseDict?["data"] as? [String : Any]), let unreadCount = dataDict["unread_count"] as? Int  {
                Utility.shared.notificationCount = unreadCount
                NotificationCenter.default.post(name: notificationNameUpdateNotificationCount, object: nil)

            }
            debugPrint(" Utility.shared.notificationCount == \( Utility.shared.notificationCount)")
        }
    }
}
