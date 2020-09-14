//
//  ExploreDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import PureLayout
import CoreStore
import HTTPStatusCodes
import ObjectMapper
import Alamofire
import FirebaseAnalytics
import EasyNotificationBadge

protocol BarDetailViewControllerDelegate: class {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem)
}

class BarDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var standardRedeemButton: GradientButton!
    
    @IBOutlet var navBarBgView: UIView!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomViewBottom: NSLayoutConstraint!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    weak var delegate: BarDetailViewControllerDelegate?

    var aboutController: BarDetailAboutViewController!
    var whatsOnController: WhatsOnViewController!
    var offersController: OffersViewController!

    var segmentedController: SJSegmentedViewController!
    
    var barId: String?
    var selectedBar: Bar?
    
    var refreshControl: UIRefreshControl!
    
    var reloadDataRequest: DataRequest?
    
    var preSelectedTabIndex = 0
    var preSelectedSubTabIndexWhatsOn = 0
    var preSelectedSubTabIndexOffers = 0
    
    var statefulView: LoadingAndErrorView!
    
    var isSegmentsSetuped = false
    var shouldSendAnalytics = false
    
    var cartBarButton: UIBarButtonItem!
    var cartButton: UIButton!
    
    var cartCount: Int = 0 {
        didSet {
            self.updateCartBadgeCount()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navBarBgView.backgroundColor = UIColor.appNavBarGrayColor()
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.isHidden = true
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.getBarDetails(isRefreshing: false)
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(didTriggerPullToRefresh(sender:)), for: .valueChanged)
        
        self.addBackButton()
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        self.cartButton = UIButton(type: .custom)
        self.cartButton.frame = CGRect(x: 0.0, y: 0.0, width: 34.0, height: 34.0)
        self.cartButton.addTarget(self, action: #selector(cartBarButtonTapped(sender:)), for: .touchUpInside)
        self.cartButton.setImage(UIImage(named: "icon_cart")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.cartBarButton = UIBarButtonItem(customView: self.cartButton)

        if let _ = self.selectedBar {
            self.setUpTitle()
            self.setUpSegmentedController()
            self.setUpBottomView()
            self.setUpCartBarButton()
        } else {
            self.getBarDetails(isRefreshing: false)
        }
        
        self.viewProfile()
        self.getCartQuantityCount()
        
        if let bar = self.selectedBar {
            Analytics.logEvent(viewBarDetailsScreen, parameters: ["bar_id" : bar.id.value])
        } else {
            Analytics.logEvent(viewBarDetailsScreen, parameters: ["bar_id" : self.barId ?? ""])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(unlimitedRedemptionDidPurchasedNotification(notif:)), name: notificationNameUnlimitedRedemptionPurchased, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(foodCartUpdatedNotification(notification:)), name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drinkCartUpdatedNotification(notification:)), name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderDidPlaced(notification:)), name: notificationNameOrderPlaced, object: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        self.setUpBottomView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameUnlimitedRedemptionPurchased, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameOrderPlaced, object: nil)
    }
    
    //MARK: My Methods
    
    func setUpSegmentedController() {
        
        self.isSegmentsSetuped = true
        
        self.aboutController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailAboutViewController") as! BarDetailAboutViewController)
        self.aboutController.bar = self.selectedBar
        self.aboutController.title = "About"
        self.aboutController.view.backgroundColor = self.containerView.backgroundColor
        
        self.whatsOnController = (self.storyboard!.instantiateViewController(withIdentifier: "WhatsOnViewController") as! WhatsOnViewController)
        self.whatsOnController.bar = self.selectedBar
        self.whatsOnController.delegate = self
        self.whatsOnController.title = "Whats On"
        self.whatsOnController.preSelectedTabIndex = self.preSelectedSubTabIndexWhatsOn
        self.whatsOnController.view.backgroundColor = self.containerView.backgroundColor
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "OffersViewController") as! OffersViewController)
        self.offersController.bar = self.selectedBar
        self.offersController.title = "Offers"
        self.offersController.delegate = self
        self.offersController.preSelectedTabIndex = self.preSelectedSubTabIndexOffers
        self.offersController.view.backgroundColor = self.containerView.backgroundColor
        
        self.segmentedController = SJSegmentedViewController(headerViewController: nil, segmentControllers: [self.aboutController, self.whatsOnController, self.offersController])
        self.segmentedController.delegate = self
        self.segmentedController.headerViewHeight = 150.0
        self.segmentedController.segmentViewHeight = 44.0
        self.segmentedController.selectedSegmentViewHeight = 1.0
        self.segmentedController.selectedSegmentViewColor = UIColor.appBlueColor()
        self.segmentedController.segmentTitleColor = UIColor.white
        self.segmentedController.segmentBackgroundColor = UIColor.appNavBarGrayColor()
        self.segmentedController.segmentTitleFont = UIFont.appRegularFontOf(size: 16.0)
        
        let shadow = SJShadow(offset: CGSize.zero, color: UIColor.black, radius: 0.0, opacity: 0.0)
        self.segmentedController.segmentShadow = shadow
        
        self.addChildViewController(self.segmentedController)
        self.segmentedController.willMove(toParentViewController: self)
        self.containerView.addSubview(self.segmentedController.view)
        
        self.segmentedController.view.autoPinEdgesToSuperviewEdges()
        
        if let scrollView = self.segmentedController.view.subviews.first as? UIScrollView {
            scrollView.bounces = true
            scrollView.refreshControl = self.refreshControl
            scrollView.backgroundColor = self.view.backgroundColor
        }
        
        self.segmentedController.setSelectedSegmentAt(self.preSelectedTabIndex, animated: false)
        self.shouldSendAnalytics = true

    }
    
    func setUpTitle() {
        
        guard let selectedBar = self.selectedBar else {
            debugPrint("Bar not available for setting up title")
            return
        }
        
        self.title = selectedBar.title.value
    }
    
    func setUpBottomView() {
        
        guard let selectedBar = self.selectedBar else {
            debugPrint("Bar not available for setting up bottomview")
            return
        }
        
        if self.selectedBar!.barType == .exclusiveBar {
            self.standardRedeemButton.isHidden = true
            self.bottomView.isHidden = true
            self.bottomViewBottom.constant = self.bottomView.frame.height

        } else if let standardOffer = self.selectedBar!.activeStandardOffer.value {
            standardRedeemButton.buttonStandardOfferType = standardOffer.type
            standardRedeemButton.setTitle(standardOffer.displayValue, for: .normal)
            standardRedeemButton.setTitleColor(UIColor.appBlackColor(), for: .normal)
        }
        
        if selectedBar.canRedeemOffer.value || selectedBar.currentlyUnlimitedRedemptionAllowed {
            self.standardRedeemButton.updateColor(withGrey: false)
        } else {
            self.standardRedeemButton.updateColor(withGrey: true)
        }
    }

    func setUpCartBarButton() {
        
        guard let selectedBar = self.selectedBar else {
            debugPrint("Bar not available for setting up cartbar button")
            return
        }
        
        if selectedBar.isInAppPaymentOn.value {
            self.navigationItem.rightBarButtonItem = self.cartBarButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    func redeemWithUserCredit(credit: Int?, canReload: Bool) {
        var userCredit: Int!
        
        if let credit = credit {
            userCredit = credit
        } else {
            let user = Utility.shared.getCurrentUser()
            userCredit = user!.credit
        }
        
        if userCredit > 0 {

            //If has credits but eligible to reload i.e. timer is zero don't allow to use credit
            if canReload {
                let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
                outOfCreditViewController.canReload = canReload
                outOfCreditViewController.hasCredits = true
                outOfCreditViewController.delegate = self
                outOfCreditViewController.modalPresentationStyle = .overCurrentContext
                self.present(outOfCreditViewController, animated: true, completion: nil)
            } else {
                let creditConsumptionController = self.storyboard?.instantiateViewController(withIdentifier: "CreditCosumptionViewController") as! CreditCosumptionViewController
                creditConsumptionController.delegate = self
                creditConsumptionController.modalPresentationStyle = .overCurrentContext
                self.present(creditConsumptionController, animated: true, completion: nil)
            }

        } else {
            let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
            outOfCreditViewController.canReload = canReload
            outOfCreditViewController.isOfferingUnlimitedRedemption = self.selectedBar!.currentlyUnlimitedRedemptionAllowed
            outOfCreditViewController.barId = self.selectedBar!.id.value
            outOfCreditViewController.delegate = self
            outOfCreditViewController.modalPresentationStyle = .overCurrentContext
            self.present(outOfCreditViewController, animated: true, completion: nil)
        }
    }
    
    func showCustomAlert(title: String, message: String) {
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = message
        cannotRedeemViewController.titleText = title
        cannotRedeemViewController.delegate = self
        cannotRedeemViewController.alertType = .normal
        cannotRedeemViewController.alignment = .center
        cannotRedeemViewController.headerImageName = "login_intro_five_a_day_5"
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        self.present(cannotRedeemViewController, animated: true, completion: nil)
    }
    
    @objc func didTriggerPullToRefresh(sender: UIRefreshControl) {
        self.getBarDetails(isRefreshing: true)
        self.whatsOnController.reset()
        self.offersController.reset()
    }
    
    func showRedeemStartViewController(offerType: OfferType, redeemType: RedeemType) {
        let redeemStartViewController = (self.storyboard!.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.offerType = offerType
        redeemStartViewController.redeemingType = redeemType
        redeemStartViewController.barId = self.selectedBar!.id.value
        redeemStartViewController.standardOfferId = self.selectedBar!.activeStandardOffer.value!.id.value
        redeemStartViewController.delegate = self
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemStartViewController, animated: true, completion: nil)
    }
    
    func getSelectedBarId() -> String? {
        var selectedBarId: String?
        
        if let selectedBar = self.selectedBar {
            selectedBarId = selectedBar.id.value
        } else if let barId = self.barId {
            selectedBarId = barId
        }
        
        return selectedBarId
    }
    
    func getAnalyticsEventName(index: Int) -> String {
        switch index {
        case 0:
            return barDetailAboutClick
        case 1:
            return barDetailDealClick
        case 2:
            return barDetailLiveOffersClick
        default:
            return "bar detail default"
        }
    }

    @objc func cartBarButtonTapped(sender: UIButton) {
        let cartNavigation = self.storyboard!.instantiateViewController(withIdentifier: "MyCartNavigation") as! UINavigationController
        cartNavigation.modalPresentationStyle = .fullScreen
        
        let myCartController = cartNavigation.viewControllers.first as! MyCartViewController
        myCartController.isComingFromBarDetails = true
        myCartController.barId = self.getSelectedBarId()!
        
        self.navigationController?.present(cartNavigation, animated: true, completion: nil)
    }
    
    func updateCartBadgeCount() {
        if self.cartCount > 0 {
            var badgeAppearance = BadgeAppearance()
            badgeAppearance.backgroundColor = UIColor.red
            badgeAppearance.textColor = UIColor.white
            badgeAppearance.textAlignment = .center
            badgeAppearance.textSize = 12
            self.cartBarButton.badge(text: "\(self.cartCount)", appearance: badgeAppearance)
        } else {
            self.cartBarButton.badge(text: nil)
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.barDetailViewController(controller: self, cancelButtonTapped: sender)
        }
    }
    
    @IBAction func getOffButtonTapped(_ sender: Any) {
        
        Analytics.logEvent(redeemOfferButtonClick, parameters: nil)
        
        guard let selectedBar = self.selectedBar else {
            debugPrint("Bar not available for redeeming standard offer")
            return
        }
    
        if selectedBar.canRedeemOffer.value {
            self.showRedeemStartViewController(offerType: OfferType.standard, redeemType: RedeemType.standard)
        } else if selectedBar.canDoUnlimitedRedemption.value && selectedBar.currentlyUnlimitedRedemptionAllowed {
            self.showRedeemStartViewController(offerType: OfferType.standard, redeemType: RedeemType.unlimitedReload)
        } else {
            //get updated User Credit from server api
            self.getReloadStatus()
        }
     
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExploreDetailToOfferDetailSegue" {
            let vc = segue.destination as! OfferDetailViewController
            vc.deal = sender as? Deal
        }
    }
}

//MARK: SJSegmentedViewControllerDelegate
extension BarDetailViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
    
        if self.shouldSendAnalytics {
            let eventName = self.getAnalyticsEventName(index: index)
            Analytics.logEvent(eventName, parameters: nil)
        }
        
        for segment in self.segmentedController.segments {
            segment.titleColor(UIColor.white)
        }
        
        let segmentTab = self.segmentedController.segments[index]
        segmentTab.titleColor(UIColor.appBlueColor())
    }
}

//MARK: RedeemStartViewControllerDelegate
extension BarDetailViewController: RedeemStartViewControllerDelegate {
    func redeemStartViewController(controller: RedeemStartViewController, redeemStatus successful: Bool, selectedIndex: Int) {
        
        if successful {
            self.setUpBottomView()
        }
    }
    
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
}

//MARK: WebService Method
extension BarDetailViewController {
    
    func getBarDetails(isRefreshing: Bool) {
        
        guard let barId = self.getSelectedBarId() else {
            self.statefulView.showErrorViewWithRetry(errorMessage: "Bar Not Found", reloadMessage: "Tap to retry")
            self.statefulView.isHidden = false
            return
        }
        
        if isRefreshing {
            self.statefulView.isHidden = true
            self.statefulView.showNothing()
        } else {
            self.statefulView.showLoading()
            self.statefulView.isHidden = false
        }
        
        let apiPath = apiPathGetBarDetail + "/" + barId
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPath, method: .get) { (response, serverError, error) in
            
            self.refreshControl.endRefreshing()
            
            guard error == nil else {
                debugPrint("Error while refreshing establishment: \(error!.localizedDescription)")
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap to retry")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Error while refreshing establishment: \(serverError!.errorMessages())")
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap to retry")
                return
            }
            
            self.statefulView.isHidden = true
            self.statefulView.showNothing()
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseData = (responseDict?["data"] as? [String : Any]) {
                var importedObject: Bar!
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    importedObject = try! transaction.importUniqueObject(Into<Bar>(), source: responseData)
                })
                
                let fetchedObject = Utility.barCodeDataStack.fetchExisting(importedObject)
                
                self.selectedBar = fetchedObject

                if !self.isSegmentsSetuped {
                    self.setUpSegmentedController()
                } else {
                    self.aboutController.reloadData(bar: self.selectedBar!)
                }
                
                self.setUpTitle()
                self.setUpBottomView()
                self.setUpCartBarButton()
                
                NotificationCenter.default.post(name: notificationNameBarDetailsRefreshed, object: self.selectedBar!)
                
            } else {
                debugPrint("Unexpected response received while getting establishment")
            }
            
        }
    }
    
    //View for statistics
    func viewProfile() {
        
        guard let barId = self.getSelectedBarId() else {
            debugPrint("Bar id not available for adding analytic")
            return
        }
        
        let params: [String: Any] = ["value": barId,
                                     "type":"profile_view"]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathView, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error while view api : \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror while view api : \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let responseDic = response as! [String : Any]
            if (responseDic["response"] as? [String : Any]) != nil {

                debugPrint("view has been updated successfully")
            
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericerror while view api : \(genericError.localizedDescription)")
            }
        }
    }
    
    func getReloadStatus() {
        
        guard let barId = self.getSelectedBarId() else {
            debugPrint("Bar id not available for getting reload status")
            return
        }
        
        self.standardRedeemButton.showLoader()
        let param = ["establishment_id" : barId]
        
        self.reloadDataRequest = APIHelper.shared.hitApi(params: param, apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            self.standardRedeemButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while getting reload status \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
               debugPrint("Error while getting reload status \(String(describing: serverError?.errorMessages()))")
               return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let redeemInfoDict = (responseDict?["data"] as? [String : Any]) {
                                
                let credit = redeemInfoDict["credit"] as! Int
                Utility.shared.userCreditUpdate(creditValue: credit)
                
                let redeemedCount = redeemInfoDict["redeemed_count"] as! Int
                if redeemedCount < 2 || self.selectedBar!.currentlyUnlimitedRedemptionAllowed {
                    
                    let redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemInfoDict)!
                    
                    var canReload = false
                    if !redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds == 0 {
                        canReload = true
                    }
                    
                    self.redeemWithUserCredit(credit: credit, canReload: canReload)
                } else {
                    self.showCustomAlert(title: "You've Reached Your Daily Limit For This Bar", message: "You have used your two offer limit here today. Don't worry, you can use credits to redeem offers here again tomorrow.")
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }
    
    func getCartQuantityCount() {
        
        var barId: String = ""
        if let id = self.barId {
            barId = id
        } else if let id = self.selectedBar?.id.value {
            barId = id
        }
        
        let params: [String : Any] = ["establishment_id" : barId]
           
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathGetCartQuantity, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting cart count: \(error!.localizedDescription)")
                return
            }
               
            guard serverError == nil else {
                debugPrint("Error while getting cart count: \(serverError!.nsError())")
                return
            }
            
            debugPrint("cart count get successfully")

            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let _ = responseDict?["count"]  {
                self.cartCount = Int("\(responseDict!["count"]!)") ?? 0
            }
        }
    }
}

//MARK: CreditCosumptionViewControllerDelegate
extension BarDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {
        self.showRedeemStartViewController(offerType: OfferType.standard, redeemType: RedeemType.credit)
    }
    
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }    
}

//MARK: OutOfCreditViewControllerDelegate
extension BarDetailViewController: OutOfCreditViewControllerDelegate {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton, selectedIndex: Int) {
        let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
        reloadNavigation.modalPresentationStyle = .fullScreen
        
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        reloadController.delegate = self
        reloadController.selectedIndex = selectedIndex
        self.present(reloadNavigation, animated: true, completion: nil)
        
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int) {
        
        let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
        inviteNavigation.modalPresentationStyle = .fullScreen
        
        let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
        inviteController.isRedeemingDeal = true
        inviteController.delegate = self
        inviteController.selectedIndex = selectedIndex
        self.present(inviteNavigation, animated: true, completion: nil)
        
    }
}

extension BarDetailViewController: ReloadViewControllerDelegate {
    func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        
    }

}

extension BarDetailViewController : InviteViewControllerDelegate {
    func inviteViewController(controller: InviteViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        
    }

}

//MARK: RedeemDealViewControllerDelegate
/*
extension BarDetailViewController: RedeemDealViewControllerDelegate {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int) {
    }
    
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int) {
        
        if error == nil {
            self.setUpBottomView()
        }
    }
}*/

//MARK: CannotRedeemViewControllerDelegate
extension BarDetailViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}

//MARK: WhatsOnViewControllerDelegate
extension BarDetailViewController: WhatsOnViewControllerDelegate {
    func whatsOnViewController(controller: WhatsOnViewController, didSelect food: Food) {
        /*
        let detailController = (self.storyboard!.instantiateViewController(withIdentifier: "WhatsOnDetailViewController") as! WhatsOnDetailViewController)
        detailController.type = .food
        detailController.food = food
        detailController.bar = self.selectedBar!
        self.navigationController?.pushViewController(detailController, animated: true)
        */
    }
    
    func whatsOnViewController(controller: WhatsOnViewController, didSelect drink: Drink) {
        /*
        let detailController = (self.storyboard!.instantiateViewController(withIdentifier: "WhatsOnDetailViewController") as! WhatsOnDetailViewController)
        detailController.type = .drink
        detailController.drink = drink
        detailController.bar = self.selectedBar!
        self.navigationController?.pushViewController(detailController, animated: true)
        */
    }
    
    func whatsOnViewController(controller: WhatsOnViewController, didSelect event: Event) {
        let eventDetailController = (self.storyboard!.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController)
        eventDetailController.event = event
        self.navigationController?.pushViewController(eventDetailController, animated: true)
    }
}

//MARK: OffersViewControllerDelegate
extension BarDetailViewController: OffersViewControllerDelegate {
    func offersViewController(controller: OffersViewController, didSelectLive live: LiveOffer) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: live)
    }
    
    func offersViewController(controller: OffersViewController, didSelectBanner banner: Deal) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: banner)
    }
    
    func offersViewController(controller: OffersViewController, didSelectExclusive exclusive: Deal) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: exclusive)
    }
}

//MARK: Notification Methods
extension BarDetailViewController {
    @objc func unlimitedRedemptionDidPurchasedNotification(notif: Notification) {
        if let barId = notif.object as? String, let bar = self.selectedBar, barId == bar.id.value {
            self.getBarDetails(isRefreshing: false)
        }
    }
    
    @objc func foodCartUpdatedNotification(notification: Notification) {
        guard let foodInfo = notification.object as? FoodCartUpdatedObject, let id = self.selectedBar?.id.value, id == foodInfo.barId else {
            return
        }
        
        if foodInfo.food.quantity.value == 0 {
            self.cartCount -= foodInfo.previousQuantity
        } else {
            self.cartCount += 1
        }
    }
    
    @objc func drinkCartUpdatedNotification(notification: Notification) {
        guard let drinkInfo = notification.object as? DrinkCartUpdatedObject, let id = self.selectedBar?.id.value, id == drinkInfo.barId else {
            return
        }
        
        if drinkInfo.drink.quantity.value == 0 {
            self.cartCount -= drinkInfo.previousQuantity
        } else {
            self.cartCount += 1
        }
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        guard let object = notification.object as? OrderItemCartUpdatedObject, let id = self.selectedBar?.id.value, id == object.barId else {
            return
        }
        
        if object.delete {
            self.cartCount -= object.previousQuantity
        } else {
            if object.stepUp {
                self.cartCount += 1
            } else {
                self.cartCount -= 1
            }
        }
    }
    
    @objc func orderDidPlaced(notification: Notification) {
        if let order = notification.object as? Order, order.barId == self.getSelectedBarId() {
            self.didTriggerPullToRefresh(sender: self.refreshControl)
            self.cartCount = 0
        }
    }
}
