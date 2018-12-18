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
import Fabric
import Crashlytics
import OneSignal
import CoreStore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var referralCode: String?
    var sharedOfferParams: SharedOfferParams?
    
    var liveOfferBarId: String?
    
    var refreshFiveADay: Bool?
    
    var visitLocationManager: CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        CoreStore.defaultStack = DataStack(
            CoreStoreSchema(
                modelVersion: "V1",
                entities: [
                    Entity<User>("User")
                ]
            )
        )
        
        try! CoreStore.addStorageAndWait()
        
        let dataStack = Utility.inMemoryStack
        try! dataStack.addStorageAndWait(InMemoryStore())
        
        self.setupAuthIfNeeded()
        
        self.customizeAppearance()
        GMSServices.provideAPIKey("AIzaSyA8lXiv-u5zrcIcQK5ROoAONbEWYzUHSK8")
        
        FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        FirebaseOptions.defaultOptions()?.deepLinkURLScheme = theBarCodeInviteScheme
        FirebaseApp.configure()
        
        Fabric.with([Crashlytics.self])
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            debugPrint("push message = \(String(describing: payload!.body))")
            debugPrint("push badge number = \(payload?.badge ?? 0)")
            debugPrint("push notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData, let notificationTypeRaw: String = additionalData["type"] as? String, let notificationType = NotificationType(rawValue: notificationTypeRaw) {
                debugPrint("additionalData = \(additionalData)")

                if notificationType == NotificationType.liveOffer, let barDict = additionalData["bar"] as? [String : Any] {
                    
                    let barId = "\(barDict["id"]!)"
                    self.liveOfferBarId = barId
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameLiveOffer), object: nil)
                } else if notificationType == NotificationType.fiveADay {
                    self.refreshFiveADay = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
                } else if notificationType == NotificationType.shareOffer {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
                } else {
                    
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.setRequiresUserPrivacyConsent(false)
        OneSignal.inFocusDisplayType = .notification
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: Utility.shared.oneSignalAppId(),
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
        self.startVisitLocationManager()
        
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        let universalUrl = userActivity.webpageURL
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(universalUrl!) { (dynamicLink, error) in
            
            guard error == nil else {
                debugPrint("Error while getting dynamic link: \(error!.localizedDescription)")
                return
            }
            
            if universalUrl?.host == dynamicLinkInviteDomain {
                if let code = Utility.shared.getReferralCodeFromUrlString(urlString: dynamicLink!.url!.absoluteString) {
                    self.referralCode = code
                } else {
                    debugPrint("Unable to parse referral code: ")
                }
                
            } else if universalUrl?.host == dynamicLinkShareOfferDomain {
                if let sharedOfferParams = Utility.shared.getSharedOfferParams(urlString: dynamicLink!.url!.absoluteString) {
                    self.sharedOfferParams = sharedOfferParams
                    self.referralCode = sharedOfferParams.referral!
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
                } else {
                    debugPrint("Unable to parse shared offer params: ")
                }
            } else {
                debugPrint("Unhandled dynamic link domain")
            }
        }
        
        return handled
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "fb182951649264383" {
            let handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options)
            return handled ?? false
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
        
        UIPickerView.appearance(whenContainedInInstancesOf: [UIView.self]).backgroundColor = UIColor.clear
    }
}

