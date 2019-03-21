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

protocol BarDetailViewControllerDelegate: class {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem)
}

class BarDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var standardRedeemButton: GradientButton!
    
    @IBOutlet var bottomView: UIView!
    @IBOutlet var bottomViewBottom: NSLayoutConstraint!
    
    weak var delegate: BarDetailViewControllerDelegate?

    var headerController: BarDetailHeaderViewController!
    
    var aboutController: BarDetailAboutViewController!
    var dealsController: BarDealsViewController!
    var offersController: BarLiveOffersViewController!
    
    var segmentedController: SJSegmentedViewController!
    
    var barId: String?
    var selectedBar: Bar?
    
    var refreshControl: UIRefreshControl!
    
    var reloadDataRequest: DataRequest?
    
    var preSelectedTabIndex = 0
    
    var statefulView: LoadingAndErrorView!
    
    var isSegmentsSetuped = false
    var shouldSendAnalytics = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        
        if let _ = self.selectedBar {
            self.setUpTitle()
            self.setUpSegmentedController()
            self.setUpBottomView()
        } else {
            self.getBarDetails(isRefreshing: false)
        }
        
        self.viewProfile()
        
        Analytics.logEvent(viewBarDetailsScreen, parameters: nil)
        
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
    
    //MARK: My Methods
    
    func setUpSegmentedController() {
        
        self.isSegmentsSetuped = true
        
        let collectionViewHeight = ((178.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        self.headerController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailHeaderViewController") as! BarDetailHeaderViewController)
        headerController.bar = self.selectedBar
        let _ = self.headerController.view
        self.headerController.collectionViewHeight.constant = collectionViewHeight
        
        self.aboutController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailAboutViewController") as! BarDetailAboutViewController)
        self.aboutController.bar = self.selectedBar
        self.aboutController.title = "About"
        self.aboutController.view.backgroundColor = self.containerView.backgroundColor
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarDealsViewController") as! BarDealsViewController)
        self.dealsController.bar = self.selectedBar
        self.dealsController.title = "Deals"
        self.dealsController.delegate = self
        self.dealsController.view.backgroundColor = self.containerView.backgroundColor
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "BarLiveOffersViewController") as! BarLiveOffersViewController)
        self.offersController.bar = self.selectedBar
        self.offersController.title = "Live Offers"
        self.offersController.delegate = self
        self.offersController.view.backgroundColor = self.containerView.backgroundColor
        
        self.aboutController.automaticallyAdjustsScrollViewInsets = false
        self.dealsController.automaticallyAdjustsScrollViewInsets = false
        self.offersController.automaticallyAdjustsScrollViewInsets = false
        
        self.segmentedController = SJSegmentedViewController(headerViewController: self.headerController, segmentControllers: [self.aboutController, self.dealsController, self.offersController])
        self.segmentedController.delegate = self
        self.segmentedController.headerViewHeight = headerViewHeight
        self.segmentedController.segmentViewHeight = 44.0
        self.segmentedController.selectedSegmentViewHeight = 1.0
        self.segmentedController.selectedSegmentViewColor = UIColor.appBlueColor()
        self.segmentedController.segmentTitleColor = UIColor.white
        self.segmentedController.segmentBackgroundColor = self.headerController.view.backgroundColor!
        self.segmentedController.segmentTitleFont = UIFont.appRegularFontOf(size: 16.0)
        
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
        
        if selectedBar.canRedeemOffer.value {
            self.standardRedeemButton.updateColor(withGrey: false)
        } else {
            self.standardRedeemButton.updateColor(withGrey: true)
        }
        
        if let standardOffer = self.selectedBar!.activeStandardOffer.value {
            standardRedeemButton.buttonStandardOfferType = standardOffer.type
            standardRedeemButton.setTitle(standardOffer.displayValue, for: .normal)
            
            setUpStandardRedeemButtonUI()
        }
    }
    
    func setUpStandardRedeemButtonUI(){
        switch self.selectedBar!.activeStandardOffer.value!.type {
        case .bronze:
            standardRedeemButton.setTitleColor(UIColor.appBlackColor(), for: .normal)
            break
        case .silver:
            standardRedeemButton.setTitleColor(UIColor.appBlackColor(), for: .normal)
            break
        case .gold:
            standardRedeemButton.setTitleColor(UIColor.appBlackColor(), for: .normal)
            break
        case .platinum:
            standardRedeemButton.setTitleColor(UIColor.appBlackColor(), for: .normal)
            break
        default:
            break
        }
    }
    
    func redeemWithUserCredit(credit: Int?, canReload: Bool) {
        var userCredit: Int!
        
        if credit == nil {
            let user = Utility.shared.getCurrentUser()
            userCredit = user!.credit
        } else {
            userCredit = credit!
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
        self.dealsController.resetDeals()
        self.offersController.resetOffers()
    }

    func moveToRedeemDealViewController(withCredit: Bool) {
       let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
        redeemDealViewController.bar = self.selectedBar
        redeemDealViewController.redeemWithCredit = withCredit
        redeemDealViewController.type = .standard
        redeemDealViewController.delegate = self
        redeemDealViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemDealViewController, animated: true, completion: nil)
   
    }
    
    func moveToRedeemStartViewController(withCredit: Bool){
        
        let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.bar = self.selectedBar
        redeemStartViewController.delegate = self
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        redeemStartViewController.redeemWithCredit = withCredit
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
            
            let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
            redeemStartViewController.delegate = self
            redeemStartViewController.type = .standard
            redeemStartViewController.bar = selectedBar
            redeemStartViewController.modalPresentationStyle = .overCurrentContext
            redeemStartViewController.redeemWithCredit = false
            self.present(redeemStartViewController, animated: true, completion: nil)
            
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

//MARK: ExploreDetailDealsViewControllerDelegate
extension BarDetailViewController: BarDealsViewControllerDelegate {
    func barDealsController(controller: BarDealsViewController, didSelectRowAt deal: Deal) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: deal)
    }
}

//MARK: ExploreDetailLiveOffersViewControllerDelegate
extension BarDetailViewController: BarLiveOffersViewControllerDelegate {
    func barLiveOffersController(controller: BarLiveOffersViewController, didSelectRowAt offer: LiveOffer) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: offer)
    }
}

//MARK: RedeemStartViewControllerDelegate
extension BarDetailViewController: RedeemStartViewControllerDelegate {
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int, withCredit: Bool) {
    
        self.moveToRedeemDealViewController(withCredit: withCredit)
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
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    importedObject = try! transaction.importUniqueObject(Into<Bar>(), source: responseData)
                })
                
                let fetchedObject = Utility.inMemoryStack.fetchExisting(importedObject)
                
                self.selectedBar = fetchedObject
                
                if !self.isSegmentsSetuped {
                    self.setUpSegmentedController()
                } else {
                    self.aboutController.reloadData(bar: self.selectedBar!)
                    self.headerController.reloadData(bar: self.selectedBar!)
                }
                
                self.setUpTitle()
                self.setUpBottomView()
                
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
                if redeemedCount < 2 {
                    
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
    
}

//MARK: CreditCosumptionViewControllerDelegate
extension BarDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {
        
        self.moveToRedeemStartViewController(withCredit: true)
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
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        reloadController.delegate = self
        reloadController.selectedIndex = selectedIndex
        self.present(reloadNavigation, animated: true, completion: nil)
        
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int) {
        
        let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
        let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
        inviteController.shouldShowCancelBarButton = true
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
extension BarDetailViewController: RedeemDealViewControllerDelegate {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int) {
    }
    
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int) {
        
        if error == nil {
            self.setUpBottomView()
        }
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension BarDetailViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}
