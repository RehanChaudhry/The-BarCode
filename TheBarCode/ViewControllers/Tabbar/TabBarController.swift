//
//  TabBarController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import OneSignal

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.registerTagForPushNotification()
        
        let tabbarItems = self.tabBar.items!
        let explore = tabbarItems[2]
        
        explore.selectedImage = #imageLiteral(resourceName: "icon_tab_explore_selected").withRenderingMode(.alwaysOriginal)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let refreshFiveDay = appDelegate.refreshFiveADay, refreshFiveDay {
            appDelegate.refreshFiveADay = false
            self.selectedIndex = 1
        } else {
            self.selectedIndex = 2
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFiveADayNotification(notification:)), name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
    }
    
    //MARK: My Methods
    func registerTagForPushNotification() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("Unable to get user for push notification tag registration")
            return
        }
        
        debugPrint("User access token: \(user.accessToken.value)")
        
        OneSignal.sendTags(["user_id" : user.userId.value])
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
            
            fiveADayController.dismiss(animated: false, completion: nil)
            self.presentedViewController?.dismiss(animated: false, completion: nil)
            
            self.selectedIndex = 1
        }
    }
}
