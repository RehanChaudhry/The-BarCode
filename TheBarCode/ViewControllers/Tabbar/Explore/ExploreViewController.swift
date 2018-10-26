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
    var dealsController: BarsWithDealsViewController!
    var liveOffersController: BarsWithLiveOffersViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    
    var reloadDataRequest: DataRequest?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.appNavBarGrayColor()
        self.segmentContainerView.backgroundColor = UIColor.clear
        
        self.setUpContainerViews()
        
        self.defaultButtonTitleColor = self.barsButton.titleColor(for: .normal)
        
        self.barsButton.sendActions(for: .touchUpInside)
        
        self.getReloadStatus()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dealRedeemedNotification(notification:)), name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil)
        
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
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil)
        
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
        self.addViewController(controller: self.barsController, parent: self.barsContainerView)
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsWithDealsViewController") as! BarsWithDealsViewController)
        self.dealsController.delegate = self
        self.addViewController(controller: self.dealsController, parent: self.dealsContainerView)
        
        self.liveOffersController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsWithLiveOffersViewController") as! BarsWithLiveOffersViewController)
        self.liveOffersController.delegate = self
        self.addViewController(controller: self.liveOffersController, parent: self.liveOffersContainerView)
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
        barDetailController.selectedBar = bar
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func updateSnackBarForType(type: SnackbarType) {
        if type == .discount {
            self.dealsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            self.liveOffersController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
        } else if type == .reload {
            self.dealsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            self.liveOffersController.snackBar.updateAppearanceForType(type: type, gradientType: .green)
            
            self.startReloadTimer()
        } else if type == .congrates {
            self.dealsController.snackBar.updateAppearanceForType(type: type, gradientType: .orange)
            self.barsController.snackBar.updateAppearanceForType(type: type, gradientType: .orange)
            self.liveOffersController.snackBar.updateAppearanceForType(type: .discount, gradientType: .orange)
        }
    }
    
    func startReloadTimer() {
        self.reloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateReloadTimer(sender: sender)
        })
    }
    
    func updateReloadTimer(sender: Timer) {
        
        guard let redeemInfo = self.redeemInfo else {
            debugPrint("Redeem info not available to update timer")
            return
        }
        
        if redeemInfo.remainingSeconds > 0 {
            self.redeemInfo!.remainingSeconds -= 1
            
            self.dealsController.snackBar.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
            self.barsController.snackBar.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
            self.liveOffersController.snackBar.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
        } else {
            self.reloadTimer?.invalidate()
            self.updateSnackBarForType(type: .congrates)
        }
        
    }
    
    func showSnackBarSpinner() {
        self.dealsController.snackBar.showLoading()
        self.barsController.snackBar.showLoading()
        self.liveOffersController.snackBar.showLoading()
    }
    
    func finishLoading() {
        self.dealsController.snackBar.hideLoading()
        self.barsController.snackBar.hideLoading()
        self.liveOffersController.snackBar.hideLoading()
    }
    
    func showError(msg: String) {
        self.dealsController.snackBar.showError(msg: msg)
        self.barsController.snackBar.showError(msg: msg)
        self.liveOffersController.snackBar.showError(msg: msg)
    }
    
    func reloadData() {
        self.barsController.dataRequest?.cancel()
        self.dealsController.dataRequest?.cancel()
        self.liveOffersController.dataRequest?.cancel()
        
        let _ = self.barsController.statefulTableView.triggerPullToRefresh()
        let _ = self.dealsController.statefulTableView.triggerPullToRefresh()
        let _ = self.liveOffersController.statefulTableView.triggerPullToRefresh()
        
        self.refreshSnackBar()
        
    }
    
    func refreshSnackBar() {
        self.reloadDataRequest?.cancel()
        self.getReloadStatus()
    }
    
    //MARK: My IBActions
    
    @IBAction func barsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .bars
        
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    @IBAction func dealsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .deals
        
        self.scrollView.scrollToPage(page: 1, animated: true)
    }
    
    @IBAction func liveOffersButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .liveOffers
        
        self.scrollView.scrollToPage(page: 2, animated: true)
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
                
                if self.redeemInfo!.isFirstRedeem {
                    self.updateSnackBarForType(type: .discount)
                } else if (!self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds == 0) {
                    self.updateSnackBarForType(type: .congrates)
                } else if (!self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds > 0) {
                    self.updateSnackBarForType(type: .reload)
                } else {
                    self.showError(msg: "Tap To Retry")
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
    func barsController(controller: BarsViewController, didSelectBar bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

//MARK: BarsWithDealsViewControllerDelegate
extension ExploreViewController: BarsWithDealsViewControllerDelegate {
    func barsWithDealsController(controller: BarsWithDealsViewController, didSelect bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

//MARK: BarsWithLiveOffersViewControllerDelegate
extension ExploreViewController: BarsWithLiveOffersViewControllerDelegate {
    func liveOffersController(controller: BarsWithLiveOffersViewController, didSelectLiveOfferOf bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

//MARK: Notification Methods
extension ExploreViewController {
    
    @objc func reloadSuccessfullNotification(notification: Notification) {
        self.reloadData()
    }
    
    @objc func dealRedeemedNotification(notification: Notification) {
        self.refreshSnackBar()
    }
    
}
