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

class TabBarController: UITabBarController {

    var shouldPresentBarDetail: Bool = false
    var shouldHandleSharedOffer: Bool = false
    
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
            self.selectedIndex = 1
        } else if appDelegate.liveOfferBarId != nil {
            self.selectedIndex = 2
            self.shouldPresentBarDetail = true
        } else if appDelegate.sharedOfferParams != nil {
            self.selectedIndex = 2
            self.shouldHandleSharedOffer = true
        } else {
            self.selectedIndex = 2
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFiveADayNotification(notification:)), name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(liveOfferNotification(notification:)), name: Notification.Name(rawValue: notificationNameLiveOffer), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(acceptSharedOfferNotification(notification:)), name: Notification.Name(rawValue: notificationNameAcceptSharedOffer), object: nil)
        
        if appDelegate.visitLocationManager == nil {
            appDelegate.startVisitLocationManager()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldPresentBarDetail {
            self.shouldPresentBarDetail = false
            self.showBarDetailForLiveOfferNotification()
        } else if self.shouldHandleSharedOffer {
            self.shouldHandleSharedOffer = false
            self.acceptSharedOffer()
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
    
    @objc func showBarDetailForLiveOfferNotification() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let barId = appDelegate.liveOfferBarId {
            let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
            let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
            barDetailController.barId = barId
            barDetailController.preSelectedTabIndex = 2
            self.topMostViewController().present(barDetailNav, animated: true, completion: nil)
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
            
         /*   let alertController = UIAlertController(title: "Shared Offer", message: "Great news! Your friend \(sharedByUserName) has just shared an awesome new offer with you. Check it out!", preferredStyle: .alert)
            
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let liveOfferNavigation = self.storyboard?.instantiateViewController(withIdentifier: "SharedOffersNavigation")
                self.topMostViewController().present(liveOfferNavigation!, animated: true, completion: nil)
            }))
            
            self.topMostViewController().present(alertController, animated: true, completion: nil)*/
            
            self.showCustomAlert(title: "Shared Offer", message: "Great news! Your friend \(sharedByUserName) has just shared an awesome new offer with you. Check it out!")
            
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
            
            self.selectedIndex = 1
        }
    }
    
    @objc func liveOfferNotification(notification: Notification) {
        self.showBarDetailForLiveOfferNotification()
    }
    
    @objc func acceptSharedOfferNotification(notification: Notification) {
        self.acceptSharedOffer()
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension TabBarController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        let liveOfferNavigation = self.storyboard?.instantiateViewController(withIdentifier: "SharedOffersNavigation")
        self.topMostViewController().present(liveOfferNavigation!, animated: true, completion: nil)
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
    }
}


extension TabBarController: UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let eventName = getSelectedTabEventName(itemTag: tabBar.selectedItem!.tag)
        Analytics.logEvent(eventName, parameters: nil)
        
    }
}
