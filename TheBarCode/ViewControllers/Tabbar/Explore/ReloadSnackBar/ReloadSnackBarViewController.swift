//
//  ReloadSnackBarViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 21/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import HTTPStatusCodes

class ReloadSnackBarViewController: UIViewController {

    var snackBar: SnackbarView = SnackbarView.loadFromNib()
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    
    var reloadDataRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.snackBar)
        self.snackBar.autoPinEdgesToSuperviewEdges()
        self.snackBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealRedeemedNotification(notification:)), name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sharedOfferRedeemedNotification(notification:)), name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.getReloadStatus()
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
    }
    
    //MARK: My Methods
    func moveToReloadVC() {
        let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
        reloadNavigation.modalPresentationStyle = .fullScreen
        
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        self.present(reloadNavigation, animated: true, completion: nil)
    }
    
    func moveToInvite() {
        let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
        inviteNavigation.modalPresentationStyle = .fullScreen
        
        let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
        inviteController.shouldShowCancelBarButton = true
        self.present(inviteNavigation, animated: true, completion: nil)
    }
    
    func showCustomAlert(title: String, message: String, typeCredit: Bool) {
        
        var redeemInfoCopy: RedeemInfo?
        if let redeemInfo = self.redeemInfo {
            redeemInfoCopy = RedeemInfo()
            redeemInfoCopy!.isFirstRedeem = redeemInfo.isFirstRedeem
            redeemInfoCopy!.remainingSeconds = redeemInfo.remainingSeconds
        }
        
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = message
        cannotRedeemViewController.titleText = title
        cannotRedeemViewController.delegate = self
        cannotRedeemViewController.alertType = typeCredit ? .credit : .discount
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        cannotRedeemViewController.redeemInfo = redeemInfoCopy
        cannotRedeemViewController.headerImageName = typeCredit ? "login_intro_credits_5" : "login_intro_reload_5"
        self.present(cannotRedeemViewController, animated: true, completion: nil)
    }
    
    func getBannerAlertText() -> (title: String, message: String) {
        
        let type = self.snackBar.type
        if type == .discount {
            return (title: "Get guaranteed discounts off your first round plus loads of other great offers!" , message: "You can start using all offers and credits now.\n\nYou can reload all offers when the counter hits 0:00:00:00\n\nInvite friends and share the offers you receive to earn more credits.")
        } else if type == .reload {
            return (title: "Reload in" , message: "When the timer hits Zero, Reload all used offers and access Credits for just £1\n\nYou are eligible to Reload every 7 days")
        } else if type == .congrates {
            return (title: "Reload" , message: "You are able to reload")
        }
        return (title: "" , message: "")
    }
    
    func updateSnackBarForType(type: SnackbarType) {
        if type == .discount {
            self.snackBar.updateAppearanceForType(type: type, gradientType: .green)
        } else if type == .reload {
            self.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            
            self.startReloadTimer()
            self.updateReloadTimer(sender: self.reloadTimer!)
        } else if type == .congrates {
            self.snackBar.updateAppearanceForType(type: type, gradientType: .orange)
        }
    }
    
    func startReloadTimer() {
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
        self.reloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateReloadTimer(sender: sender)
        })
        RunLoop.current.add(self.reloadTimer!, forMode: .commonModes)
    }
    
    func updateReloadTimer(sender: Timer) {
        
        guard let redeemInfo = self.redeemInfo else {
            debugPrint("Redeem info not available to update timer")
            return
        }
        
        if redeemInfo.remainingSeconds > 0 {
            self.redeemInfo!.remainingSeconds -= 1
            self.snackBar.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
        } else {
            self.reloadTimer?.invalidate()
            self.updateSnackBarForType(type: .congrates)
        }
        
    }
}

//MARK: Webservices Methods
extension ReloadSnackBarViewController {
    func getReloadStatus() {
        
        self.snackBar.showLoading()
        self.reloadDataRequest?.cancel()
        
        self.reloadDataRequest = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting reload status \(String(describing: error?.localizedDescription))")
                self.snackBar.showError(msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload
                    
                    self.updateSnackBarForType(type: .discount)
                    self.snackBar.hideLoading()
                    
                } else {
                    debugPrint("Error while getting reload status \(String(describing: serverError?.errorMessages()))")
                    self.snackBar.showError(msg: serverError!.errorMessages())
                }
                
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let redeemInfoDict = (responseDict?["data"] as? [String : Any]) {
                
                self.redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemInfoDict)!
                self.redeemInfo!.canReload = true
                
                let credit = redeemInfoDict["credit"] as! Int
                Utility.shared.userCreditUpdate(creditValue: credit)
                
                if self.redeemInfo!.isFirstRedeem {
                    self.updateSnackBarForType(type: .discount)
                } else if (!self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds == 0) {
                    self.updateSnackBarForType(type: .congrates)
                } else if (!self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds > 0) {
                    self.updateSnackBarForType(type: .reload)
                } else {
                    self.snackBar.showError(msg: "Tap To refresh")
                }
                
                self.snackBar.hideLoading()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.snackBar.showError(msg: genericError.localizedDescription)
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }
}

//MARK: SnackbarViewDelegate
extension ReloadSnackBarViewController:  SnackbarViewDelegate {
    func snackbarView(view: SnackbarView, creditButtonTapped sender: UIButton) {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User not saved")
            return
        }
        
        self.showCustomAlert(title: "You have \(user.credit) Credits", message: "Use credits to redeem unique Barcode offers. Share offers and invite friends and we will reward you with more credits", typeCredit: true)
    }
    
    func snackbarView(view: SnackbarView, bannerButtonTapped sender: UIButton) {
        
        if view.type == SnackbarType.congrates {
            self.moveToReloadVC()
        } else {
            let text = self.getBannerAlertText()
            self.showCustomAlert(title: text.title, message: text.message, typeCredit: false)
        }
    }
    
}

//MARK: CannotRedeemViewControllerDelegate
extension ReloadSnackBarViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        
        if controller.alertType == .credit || controller.alertType == .discount {
            self.moveToInvite()
        }
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}

//MARK: NSNotification Methods
extension ReloadSnackBarViewController {
    @objc func applicationDidBecomeActive(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.getReloadStatus()
        }
    }
    
    @objc func reloadSuccessfullNotification(notification: Notification) {
        self.getReloadStatus()
    }
    
    @objc func dealRedeemedNotification(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.getReloadStatus()
        }
    }
    
    @objc func sharedOfferRedeemedNotification(notification: Notification) {
        self.getReloadStatus()
    }
}
