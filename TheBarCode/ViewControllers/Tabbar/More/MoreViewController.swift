//
//  MoreViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import OneSignal
import FirebaseAnalytics

class MoreViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var menuItems: [MenuItem] = []
    
    var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 270, height: 21))
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.appBoldFontOf(size: 16.0)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "Welcome, Phillip May"
        self.navigationItem.titleView = titleLabel
        
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.rowHeight = 70.0
        self.tableView.estimatedRowHeight = 70.0
        self.tableView.tableFooterView = UIView()
        
        self.menuItems = MenuItemType.allMenuItems()
        
        self.tableView.register(cellType: MenuCell.self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBadgeCountNotification(notif:)), name: notificationNameUpdateNotificationCount, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleLabel.text = "Welcome, \(Utility.shared.getCurrentUser()!.fullName.value)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameUpdateNotificationCount, object: nil)
    }
    
    
    //MARK: MyMethods
    func getAnalyticsEventNameForMenuItemType(itemType: MenuItemType) -> String {
        switch itemType {
        case .offerWallet:
            return offerWalletClick
        case .myReservations:
            return myReservationMenuClick
        case .splitPayment:
            return splitPaymentMenuClick
        case .notification:
            return notificationMenuClick
        case .accountSettings:
            return accountSettingsClick
        case .myAddresses:
            return myAddressesClick
        case .myCards:
            return myCardsClick
        case .notificationSettings:
            return notificationSettingsClick
        case .preferences:
            return preferencesMenuClick
        case .reload:
            return  reloadMenuClick
        case .faqs:
            return faqMenuClick
        case .rules:
            return redemptionReloadRulesMenuClick
        case .privacyPolicy:
            return privacyPolicyClick
        case .signOut:
            return signOutClick
        }
    }
    
    
    @objc func updateBadgeCountNotification(notif: Notification) {
        self.tableView.reloadData()
     }
}

//MARK: UITableViewDelegate, UITableViewDataSource

extension MoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self)
        cell.setUpCell(menuItem: menuItems[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let menuItem = menuItems[indexPath.row]
        let eventName = getAnalyticsEventNameForMenuItemType(itemType: menuItem.type)
        Analytics.logEvent(eventName, parameters: nil)
        
        if menuItem.type == .signOut {
            let alertController = UIAlertController(title: "Confirm", message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (action) in
                Utility.shared.logout()
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                
            }))
            let cell = self.tableView.cellForRow(at: indexPath)
            alertController.popoverPresentationController?.sourceView = cell ?? self.view
            self.tabBarController?.present(alertController, animated: true, completion: nil)
        } else if menuItem.type == .preferences {
            let navController = self.storyboard?.instantiateViewController(withIdentifier: menuItem.type.description().storyboardId) as! UINavigationController
            navController.modalPresentationStyle = .fullScreen
            
            let categoriesController = navController.viewControllers.first as! CategoryFilterViewController
            categoriesController.comingForUpdatingPreference = true
            self.tabBarController?.present(navController, animated: true, completion: nil)
        }
        else {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: menuItem.type.description().storyboardId)
            controller?.modalPresentationStyle = .fullScreen
            self.tabBarController?.present(controller!, animated: true, completion: nil)
        }
    }
}
