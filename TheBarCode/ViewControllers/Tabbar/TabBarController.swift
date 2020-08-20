//
//  TabBarController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import OneSignal
import CoreStore
import FirebaseAnalytics
import BugfenderSDK
import FirebaseCrashlytics

class TabBarController: UITabBarController {

    var shouldPresentBarDetail: Bool = false
    var shouldHandleSharedOffer: Bool = false
    var shouldHandleSharedEvent: Bool = false
    
    var showingSharedEventAlert: Bool = false
    var showingSharedOfferAlert: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.registerTagForPushNotification()
        
        let tabbarItems = self.tabBar.items!
        let explore = tabbarItems[2]
        
        explore.selectedImage = #imageLiteral(resourceName: "icon_tab_explore_selected").withRenderingMode(.alwaysOriginal)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let refreshFiveDay = appDelegate.refreshFiveADay, refreshFiveDay {
            appDelegate.refreshFiveADay = false
            self.selectedIndex = 0
        } else if appDelegate.liveOfferBarId != nil ||
            appDelegate.chalkboardBarId != nil ||
            appDelegate.exclusiveBarId != nil ||
            appDelegate.eventBarId != nil {
            self.selectedIndex = 2
            self.shouldPresentBarDetail = true
        } else if appDelegate.sharedOfferParams != nil {
            self.selectedIndex = 2
            self.shouldHandleSharedOffer = true
        } else if appDelegate.sharedEventParams != nil {
            self.selectedIndex = 2
            self.shouldHandleSharedEvent = true
        } else {
            self.selectedIndex = 2
        }
        
        Crashlytics.crashlytics().setUserID(Utility.shared.getCurrentUser()?.userId.value ?? "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(acceptSharedEventNotification(notification:)), name: notificationNameAcceptSharedEvent, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFiveADayNotification(notification:)), name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(liveOfferNotification(notification:)), name: Notification.Name(rawValue: notificationNameLiveOffer), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(acceptSharedOfferNotification(notification:)), name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(chalkboardOfferNotification(notification:)), name: notificationNameChalkboard, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(exclusiveOfferNotification(notification:)), name: notificationNameExclusive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventNotification(notification:)), name: notificationNameEvent, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(voucherNotification(notification:)), name: notificationNameVoucher, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMoreBadgeCount(notification:)), name: notificationNameUpdateNotificationCount, object: nil)

        if appDelegate.visitLocationManager == nil {
            appDelegate.startVisitLocationManager()
        }
        
        self.saveLastAppOpen()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldPresentBarDetail {
            self.shouldPresentBarDetail = false
            self.showBarDetail()
        } else if self.shouldHandleSharedOffer {
            self.shouldHandleSharedOffer = false
            self.acceptSharedOffer()
        } else if self.shouldHandleSharedEvent {
            self.shouldHandleSharedEvent = false
            self.acceptSharedEvent()
        }
        
        if  Utility.shared.notificationCount > 0 {
            let unreadCount = Utility.shared.notificationCount > 9 ? "9+" : "\(Utility.shared.notificationCount)"
            self.tabBar.items?[4].badgeValue = unreadCount
        } else {
            self.tabBar.items?[4].badgeValue = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameLiveOffer), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: notificationNameAcceptSharedEvent, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: notificationNameEvent, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameChalkboard, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameExclusive, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: notificationNameVoucher, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameUpdateNotificationCount, object: nil)

        debugPrint("Tabbarcontroller deinit called")
        
    }
    
    //MARK: My Methods
    func showCustomAlert(title: String, message: String) {
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = message
        cannotRedeemViewController.titleText = title
        cannotRedeemViewController.delegate = self
        cannotRedeemViewController.alertType = .normal
        cannotRedeemViewController.headerImageName = "login_intro_five_a_day_5"
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        self.present(cannotRedeemViewController, animated: true, completion: nil)
    }
    
    func registerTagForPushNotification() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("Unable to get user for push notification tag registration")
            return
        }
        
        debugPrint("User access token: \(user.accessToken.value)")
        
        OneSignal.sendTags(["user_id" : user.userId.value])
        
        Bugfender.setDeviceString("id: \(user.userId.value) fullName: \(user.fullName.value)", forKey: "user")
        
    }
    
    @objc func showBarDetail() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        barDetailNav.modalPresentationStyle = .fullScreen
        
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        if let barId = appDelegate.chalkboardBarId {
            barDetailController.barId = barId
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexOffers = 0
            self.topMostViewController().present(barDetailNav, animated: true) {
                appDelegate.chalkboardBarId = nil
            }
        } else if let barId = appDelegate.exclusiveBarId {
            barDetailController.barId = barId
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexOffers = 1
            self.topMostViewController().present(barDetailNav, animated: true) {
                appDelegate.exclusiveBarId = nil
            }
        } else if let barId = appDelegate.eventBarId {
            barDetailController.barId = barId
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexOffers = 0
            self.topMostViewController().present(barDetailNav, animated: true) {
                appDelegate.eventBarId = nil
            }
        } else {
            debugPrint("Live offer notification AppDelegate object is nil")
        }
        
    }
    
    func acceptSharedOffer() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let sharedOfferParams = appDelegate.sharedOfferParams else {
            debugPrint("Could not accept shared offer because params not available")
            return
        }
        
        guard Utility.shared.getCurrentUser()?.userId.value != sharedOfferParams.sharedBy else {
            self.topMostViewController().showAlertController(title: "Sharing Offer", msg: "You cannot share an offer with your self. Share offer with your friends and family to get and avail credits.")
            appDelegate.sharedOfferParams = nil
            appDelegate.referralCode = nil
            return
        }
        
        let params: [String : Any] = ["shared_by" : sharedOfferParams.sharedBy!,
                                      "offer_id" : sharedOfferParams.offerId!]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathSharedOffers, method: .post) { (response, serverError, error) in
            
            appDelegate.sharedOfferParams = nil
            appDelegate.referralCode = nil
            
            guard error == nil else {
                self.topMostViewController().showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.topMostViewController().showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            var sharedByUserName = sharedOfferParams.sharedByName!
            sharedByUserName = sharedByUserName.replacingOccurrences(of: "+", with: " ")
            
            NotificationCenter.default.post(name: notificationNameReloadAllSharedOffers, object: nil)
            
            self.showCustomAlert(title: "Shared Offer", message: "Great news! Your friend \(sharedByUserName) has just shared an awesome new offer with you. Check it out!")
            
            self.showingSharedOfferAlert = true
            
        }
        
    }
    
    func acceptSharedEvent() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let sharedEventParams = appDelegate.sharedEventParams else {
            debugPrint("Could not accept event because params not available")
            return
        }
        
        guard Utility.shared.getCurrentUser()?.userId.value != sharedEventParams.sharedBy else {
            self.topMostViewController().showAlertController(title: "Sharing Event", msg: "You cannot share an event with your self. Share event with your friends and family.")
            appDelegate.sharedEventParams = nil
            appDelegate.referralCode = nil
            return
        }
        
        let params: [String : Any] = ["shared_by" : sharedEventParams.sharedBy!,
                                      "event_id" : sharedEventParams.eventId!]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathSharedEvents, method: .post) { (response, serverError, error) in
            
            appDelegate.sharedEventParams = nil
            appDelegate.referralCode = nil
            
            guard error == nil else {
                self.topMostViewController().showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.topMostViewController().showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            var sharedByUserName = sharedEventParams.sharedByName!
            sharedByUserName = sharedByUserName.replacingOccurrences(of: "+", with: " ")
            
            NotificationCenter.default.post(name: notificationNameReloadAllSharedEvents, object: nil)
            
            self.showCustomAlert(title: "Shared Event", message: "Great news! Your friend \(sharedByUserName) has just shared an awesome event with you. Check it out!")
            
            self.showingSharedEventAlert = true
            
        }
        
    }
    
    //to get selected tab we set tag no form 0 to 4 in storyboard so we can identify which controller has been selected by user to log event on firebase analytics 
    func getSelectedTabEventName(itemTag: Int) -> String {
        switch itemTag {
        case 0:
            return inviteTabClick
        case 1:
            return fiveADayTabClick
        case 2:
            return exploreTabClick
        case 3:
            return favouriteTabClick
        case 4:
            return moreTabClick
        default:
            return "default case tab clicked"
        }
    }
    
    func voucherRedirection() {
        let exploreViewController = ((self.viewControllers![2] as! UINavigationController).viewControllers[0] as! ExploreViewController)
        
        if exploreViewController.isViewLoaded {
            exploreViewController.reloadData()
        } else {
            let _ = exploreViewController.view
        }
                 
        if exploreViewController.topMostViewController() != exploreViewController {
            exploreViewController.dismiss(animated: false, completion: nil)
        }

        self.presentedViewController?.dismiss(animated: false, completion: nil)
                 
        self.selectedIndex = 2
        
        NotificationCenter.default.post(name: notificationNameSearchVoucher, object: nil)
    }
}

//MARK: Notification Methods
extension TabBarController {
    @objc func refreshFiveADayNotification(notification: Notification) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let refreshFiveDay = appDelegate.refreshFiveADay, refreshFiveDay {
            appDelegate.refreshFiveADay = false
            
            let fiveADayController = ((self.viewControllers![1] as! UINavigationController).viewControllers[0] as! FiveADayViewController)
            if fiveADayController.isViewLoaded {
                fiveADayController.reloadData()
            } else {
                let _ = fiveADayController.view
            }
            
            if fiveADayController.topMostViewController() != fiveADayController {
                fiveADayController.dismiss(animated: false, completion: nil)
            }

            self.presentedViewController?.dismiss(animated: false, completion: nil)
            
            self.selectedIndex = 0
        }
    }
    
    @objc func liveOfferNotification(notification: Notification) {
        self.showBarDetail()
    }
    
    @objc func chalkboardOfferNotification(notification: Notification) {
        self.showBarDetail()
    }
    
    @objc func exclusiveOfferNotification(notification: Notification) {
        self.showBarDetail()
    }
    
    @objc func eventNotification(notification: Notification) {
        self.showBarDetail()
    }
    
    @objc func acceptSharedOfferNotification(notification: Notification) {
        self.acceptSharedOffer()
    }
    
    @objc func acceptSharedEventNotification(notification: Notification) {
        self.acceptSharedEvent()
    }
    
    @objc func voucherNotification(notification: Notification) {
        self.voucherRedirection()
    }
    
    @objc func updateMoreBadgeCount(notification: Notification) {
        debugPrint("updateMoreBadgeCount")
        if  Utility.shared.notificationCount > 0 {
            let unreadCount = Utility.shared.notificationCount > 9 ? "9+" : "\(Utility.shared.notificationCount)"
            self.tabBar.items?[4].badgeValue = unreadCount
        } else {
            self.tabBar.items?[4].badgeValue = nil
        }
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension TabBarController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        
        if self.showingSharedEventAlert {
            let sharedEventNavigation = self.storyboard!.instantiateViewController(withIdentifier: "SharedEventNavigation") as! UINavigationController
            sharedEventNavigation.modalPresentationStyle = .fullScreen
            self.topMostViewController().present(sharedEventNavigation, animated: true, completion: nil)
        } else if self.showingSharedOfferAlert {
            let liveOfferNavigation = self.storyboard?.instantiateViewController(withIdentifier: "SharedOffersNavigation")
            liveOfferNavigation?.modalPresentationStyle = .fullScreen
            self.topMostViewController().present(liveOfferNavigation!, animated: true, completion: nil)
        }
        
        self.showingSharedEventAlert = false
        self.showingSharedOfferAlert = false
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        self.showingSharedEventAlert = false
        self.showingSharedOfferAlert = false
    }
}

//MARK: UITabBarControllerDelegate
extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let eventName = getSelectedTabEventName(itemTag: tabBar.selectedItem!.tag)
        Analytics.logEvent(eventName, parameters: nil)
    }
}

//MARK: Webservices Methods
extension TabBarController {
    func saveLastAppOpen() {
        
        let params: [String: Any] = ["type" : "app_view"]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathView, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error while view api : \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror while view api : \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            if let _ = (response as? [String : Any])?["response"] as? [String : Any] {
                debugPrint("view has been updated successfully")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericerror while view api : \(genericError.localizedDescription)")
            }
        }
    }
}
