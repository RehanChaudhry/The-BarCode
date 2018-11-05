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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var inviteUrlString: String?
    
    var liveOfferBar: Bar?
    var refreshFiveADay: Bool?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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

                if notificationType == NotificationType.liveOffer {
                    
                } else if notificationType == NotificationType.fiveADay {
                    self.refreshFiveADay = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
                } else {
                    
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.setRequiresUserPrivacyConsent(false)
        OneSignal.inFocusDisplayType = .notification
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "87a21c8e-cfee-4b79-8eef-23e692c64eca",
                                        handleNotificationAction: notificationOpenedBlock,
                                        settings: onesignalInitSettings)
        
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
            
            self.inviteUrlString = dynamicLink!.url!.absoluteString
            
        }
        
        return handled
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if url.scheme == "fb182951649264383" {
            let handled = FBSDKApplicationDelegate.sharedInstance()?.application(app, open: url, options: options)
            return handled ?? false
        } else if url.scheme?.lowercased() == theBarCodeInviteScheme.lowercased() {
            self.inviteUrlString = url.absoluteString
            return true
        }
        
        return false
        
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

