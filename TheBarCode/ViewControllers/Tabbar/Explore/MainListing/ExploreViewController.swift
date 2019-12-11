//
//  ExploreViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import HTTPStatusCodes
import ObjectMapper
import Alamofire
import FirebaseAnalytics

enum ExploreType: String {
    case bars = "bars", deals = "deals", liveOffers = "live_offers"
}

enum DisplayType: String {
    case list = "list", map = "map"
}

class ExploreViewController: UIViewController {

    @IBOutlet var tempView: UIView!
    
    @IBOutlet var segmentContainerView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var barsContainerView: UIView!
    @IBOutlet var dealsContainerView: UIView!
    @IBOutlet var liveOffersContainerView: UIView!
    
    @IBOutlet var dealsButton: UIButton!
    @IBOutlet var barsButton: UIButton!
    @IBOutlet var liveOffersButton: UIButton!
    
    var exploreType = ExploreType.bars
    
    var barsController: BarsViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    
    var reloadDataRequest: DataRequest?
    
    var shouldSendAnalytics = false //first time should not send analytics
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.definesPresentationContext = true
        
        self.view.backgroundColor = UIColor.appNavBarGrayColor()
        self.segmentContainerView.backgroundColor = UIColor.clear
        
        self.setUpContainerViews()
        
        self.defaultButtonTitleColor = self.barsButton.titleColor(for: .normal)
        
        self.barsButton.sendActions(for: .touchUpInside)
        
        //now can send analytics
        shouldSendAnalytics = true
        
        self.getReloadStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealRedeemedNotification(notification:)), name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sharedOfferRedeemedNotification(notification:)), name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        
        Analytics.logEvent(viewExploreScreen, parameters: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func setUpSegmentedButtons() {
        self.dealsButton.titleLabel?.textAlignment = .center
        self.barsButton.titleLabel?.textAlignment = .center
        self.liveOffersButton.titleLabel?.textAlignment = .center
    }
    
    func resetSegmentedButton() {
        self.dealsButton.backgroundColor = self.tempView.backgroundColor
        self.barsButton.backgroundColor = self.tempView.backgroundColor
        self.liveOffersButton.backgroundColor = self.tempView.backgroundColor
        
        self.dealsButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.barsButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.liveOffersButton.setTitleColor(defaultButtonTitleColor, for: .normal)
    }
    
    func setUpContainerViews() {
        self.barsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsViewController") as! BarsViewController)
        self.barsController.delegate = self
        self.barsController.snackBar.delegate = self
        self.addViewController(controller: self.barsController, parent: self.barsContainerView)
    }
    
    func addViewController(controller: UIViewController, parent: UIView) {
        self.addChildViewController(controller)
        controller.willMove(toParentViewController: self)
        
        parent.addSubview(controller.view)
        
        controller.view.autoPinEdgesToSuperviewEdges()
    }
    
    func moveToBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.barId = bar.id.value
        
//        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        
        switch self.exploreType {
        case .liveOffers:
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexOffers = 2
        case .deals:
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexOffers = 1
        default:
            barDetailController.preSelectedTabIndex = 0
            barDetailController.preSelectedSubTabIndexOffers = 0
        }
        
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func moveToBarDetail(barId: String) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.barId = barId
        barDetailController.delegate = self
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func updateSnackBarForType(type: SnackbarType) {
        if type == .discount {
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
        } else if type == .reload {
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            self.startReloadTimer()
            self.updateReloadTimer(sender: self.reloadTimer!)
        } else if type == .congrates {
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .orange)
        }
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
        
        let type = barsController.snackBar.type
        if type == .discount {
            return (title: "Get guaranteed discounts off your first round plus loads of other great offers!" , message: "You can start using all offers and credits now.\n\nYou can reload all offers when the counter hits 0:00:00:00\n\nInvite friends and share the offers you receive to earn more credits.")
        } else if type == .reload {
            return (title: "Reload in" , message: "When the timer hits Zero, Reload all used offers and access Credits for just £1\n\nYou are eligible to Reload every 7 days")
        } else if type == .congrates {
            return (title: "Reload" , message: "You are able to reload")
        }
        return (title: "" , message: "")
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
            self.barsController.snackBar.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
        } else {
            self.reloadTimer?.invalidate()
            self.updateSnackBarForType(type: .congrates)
        }
        
    }
    
    func showSnackBarSpinner() {
        self.barsController.snackBar.showLoading()
    }
    
    func finishLoading() {
        self.barsController.snackBar.hideLoading()
    }
    
    func showError(msg: String) {
        self.barsController.snackBar.showError(msg: msg)
    }
    
    func reloadData() {
        self.barsController.dataRequest?.cancel()
        
        let _ = self.barsController.statefulTableView.triggerPullToRefresh()

        self.refreshSnackBar()
    }
    
    func refreshSnackBar() {
        self.reloadDataRequest?.cancel()
        self.getReloadStatus()
    }
    
    func resetSearchBar(){
        self.barsController.searchBar.resignFirstResponder()
    }
    
    func moveToReloadVC() {
        let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        self.present(reloadNavigation, animated: true, completion: nil)
    }
    
    func moveToInvite() {
        let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
        let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
        inviteController.shouldShowCancelBarButton = true
        self.present(inviteNavigation, animated: true, completion: nil)
    }
    
    func moveToSearch(withPreferences: Bool, withStandardOffer: Bool) {
        let searchNavigationController = self.storyboard!.instantiateViewController(withIdentifier: "SearchNavigationController") as! UINavigationController
        searchNavigationController.modalTransitionStyle = .crossDissolve
        let searchController = searchNavigationController.viewControllers.first as! SearchViewController
//        searchController.searchType = self.exploreType
        let _ = searchController.view
        
        var shouldBecomeFirstResponder: Bool = true
        
        if withPreferences {
            let categoriesController = self.storyboard?.instantiateViewController(withIdentifier: "CategoryFilterViewController") as! CategoryFilterViewController
            categoriesController.shouldDismiss = true
            categoriesController.delegate = searchController
            searchNavigationController.setViewControllers([searchController, categoriesController], animated: false)
            shouldBecomeFirstResponder = false
        } else if withStandardOffer {
            let standardOfferController = (self.storyboard!.instantiateViewController(withIdentifier: "StandardOffersViewController") as! StandardOffersViewController)
            standardOfferController.shouldDismiss = true
            standardOfferController.delegate = searchController
            searchNavigationController.setViewControllers([searchController, standardOfferController], animated: false)
            shouldBecomeFirstResponder = false
        }
        
        self.present(searchNavigationController, animated: true) {
            
        }
        
        if shouldBecomeFirstResponder {
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func barsButtonTapped(sender: UIButton) {
        
        if shouldSendAnalytics { //when application launched or from login first time analytics not send,  after that application should track application clicks
            Analytics.logEvent(barTabClickFromExplore, parameters: nil)
        }
        
        self.resetSegmentedButton()
        self.resetSearchBar()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .bars
        self.scrollView.scrollToPage(page: 0, animated: true)
        self.barsController.statefulTableView.innerTable.reloadData()
    }

}

//MARK: Webservices Methods
extension ExploreViewController {
    func getReloadStatus() {
        
        self.showSnackBarSpinner()
        
        self.reloadDataRequest = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting reload status \(String(describing: error?.localizedDescription))")
                self.showError(msg: error!.localizedDescription)
                
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload
                    
                    self.updateSnackBarForType(type: .discount)
                    self.finishLoading()
                    
                } else {
                    debugPrint("Error while getting reload status \(String(describing: serverError?.errorMessages()))")
                    self.showError(msg: serverError!.errorMessages())
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
                    self.showError(msg: "Tap To refresh")
                }
                
                self.finishLoading()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showError(msg: genericError.localizedDescription)
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }
}

//MARK: BarsViewControllerDelegate
extension ExploreViewController: BarsViewControllerDelegate {
    
    func barsController(controller: BarsViewController, standardOfferButtonTapped sender: UIButton) {
        self.moveToSearch(withPreferences: false, withStandardOffer: true)
    }
    
    func barsController(controller: BarsViewController, didSelectBar bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
    
    func barsController(controller: BarsViewController, refreshSnackBar snack: SnackbarView) {
        self.refreshSnackBar()
    }
    
    func barsController(controller: BarsViewController, searchButtonTapped sender: UIButton) {
        self.moveToSearch(withPreferences: false, withStandardOffer: false)
    }
    
    func barsController(controller: BarsViewController, preferncesButtonTapped sender: UIButton) {
        self.moveToSearch(withPreferences: true, withStandardOffer: false)
    }
    
    func barsController(controller: BarsViewController, didSelectBar barId: String) {
        self.moveToBarDetail(barId: barId)
    }
}

//MARK: Notification Methods
extension ExploreViewController {
    
    @objc func reloadSuccessfullNotification(notification: Notification) {
        self.reloadData()
    }
    
    @objc func dealRedeemedNotification(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.refreshSnackBar()
        }
    }
    
    @objc func sharedOfferRedeemedNotification(notification: Notification) {
        self.refreshSnackBar()
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.refreshSnackBar()
        }
    }
    
}

//MARK: BarDetailViewControllerDelegate
extension ExploreViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
    }
}

//MARK: SnackbarViewDelegate
extension ExploreViewController: SnackbarViewDelegate {
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
extension ExploreViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        
        if controller.alertType == .credit {
           self.moveToInvite()
        } else if controller.alertType == .discount {
            self.moveToInvite()
        }
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}
