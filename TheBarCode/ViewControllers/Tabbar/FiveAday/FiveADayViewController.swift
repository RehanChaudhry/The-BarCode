//
//  FiveADayViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView
import ObjectMapper
import CoreStore
import Alamofire
import HTTPStatusCodes
import FirebaseAnalytics

class FiveADayViewController: UIViewController {

    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var deals : [FiveADayDeal] = []
    
    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    var reloadDataRequest: DataRequest?

    var canSendStats: Bool = false
    var lastSentStatsIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.definesPresentationContext = true
        
        self.pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.pageControl.numberOfPages = deals.count
        self.pageControl.currentPage = 0
        
        self.pagerView.isInfinite = true
        self.pagerView.automaticSlidingInterval = 4.0
        self.pagerView.backgroundColor = .clear
        self.pagerView.delegate = self
        self.pagerView.dataSource = self
        self.pagerView.register(FiveADayCollectionViewCell.nib, forCellWithReuseIdentifier: FiveADayCollectionViewCell.reuseIdentifier)
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.reloadData()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
        
        Analytics.logEvent(viewFiveADayScreen, parameters: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cellWidth = (self.view.frame.width / 100.0 * 85.0)
        let cellHeight = self.pagerView.frame.size.height
        
        self.pagerView.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.canSendStats = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.canSendStats = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
    }
    
    //MARK: My Methods
    
    func reloadData() {
        self.dataRequest?.cancel()
        self.getFiveADayDeals()
    }
    
    func showBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func showDirection(bar: Bar) {

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=driving",bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func showDealDetail(deal: FiveADayDeal) {
        let fiveADayDetailViewController = (self.storyboard?.instantiateViewController(withIdentifier: "FiveADayDetailViewController") as! FiveADayDetailViewController)
        fiveADayDetailViewController.modalPresentationStyle = .overCurrentContext
        fiveADayDetailViewController.deal = deal
        fiveADayDetailViewController.delegate = self
        self.present(fiveADayDetailViewController, animated: true, completion: nil)
    }
    
    func moveToRedeemDealViewController(withCredit: Bool, selectedIndex: Int) {
        
        guard selectedIndex != NSNotFound else {
            debugPrint("Index not found for deal redumtion")
            return
        }
        
        let deal = self.deals[selectedIndex]
        
        let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
        redeemDealViewController.deal = deal
        redeemDealViewController.redeemWithCredit = withCredit
        redeemDealViewController.delegate = self
        redeemDealViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemDealViewController, animated: true, completion: nil)
    }
    
    
    func redeemWithUserCredit(credit: Int?, index: Int, canReload: Bool) {
        var userCredit: Int!
        
        if credit == nil {
            let user = Utility.shared.getCurrentUser()
            userCredit = user!.credit
        } else {
            userCredit = credit!
        }
        
        self.pagerView.automaticSlidingInterval = 0.0
        if userCredit > 0 {
            
            //If has credits but eligible to reload i.e. timer is zero don't allow to use credit
            if canReload {
                let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
                outOfCreditViewController.canReload = canReload
                outOfCreditViewController.hasCredits = true
                outOfCreditViewController.delegate = self
                outOfCreditViewController.modalPresentationStyle = .overCurrentContext
                outOfCreditViewController.selectedIndex = index
                self.present(outOfCreditViewController, animated: true, completion: nil)
            } else {
                let creditConsumptionController = self.storyboard?.instantiateViewController(withIdentifier: "CreditCosumptionViewController") as! CreditCosumptionViewController
                creditConsumptionController.delegate = self
                creditConsumptionController.modalPresentationStyle = .overCurrentContext
                creditConsumptionController.selectedIndex = index
                self.present(creditConsumptionController, animated: true, completion: nil)
            }
            
        } else {
            let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
            outOfCreditViewController.canReload = canReload
            outOfCreditViewController.delegate = self
            outOfCreditViewController.modalPresentationStyle = .overCurrentContext
            outOfCreditViewController.selectedIndex = index
            self.present(outOfCreditViewController, animated: true, completion: nil)
        }
    }
    
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
    
    func updateStatsIfNeeded() {
        if let collectionView = self.pagerView.subviews.first?.subviews.first as? UICollectionView {
            let point = self.view.convert(self.view.center, to: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                debugPrint("indexPath item: \(indexPath.item)")
                
                if self.lastSentStatsIndexPath != indexPath {
                    self.lastSentStatsIndexPath = indexPath
                    
                    let deal = self.deals[indexPath.item]
                    self.viewedOffer(deal: deal)
                }
            } else {
                debugPrint("indexpath not found")
            }
        } else {
            debugPrint("collectionview not found")
        }
    }
    
}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension FiveADayViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        self.updateStatsIfNeeded()
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.updateStatsIfNeeded()
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return true
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return deals.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let identifier = FiveADayCollectionViewCell.reuseIdentifier
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: identifier, at: index) as! FiveADayCollectionViewCell
        cell.delegate = self
        cell.setUpCell(deal: self.deals[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        let fiveADayCell = cell as? FiveADayCollectionViewCell
        fiveADayCell?.setUpRedeemButton(deal: self.deals[index])
    }
    
    func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        let fiveADayCell = cell as? FiveADayCollectionViewCell
        fiveADayCell?.stopTimer()
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
      
        self.pagerView.automaticSlidingInterval = 0.0
        let deal = self.deals[index]
        if let bar = deal.establishment.value {
            self.showBarDetail(bar: bar)
        } else {
            debugPrint("Bar of FiveADayDeal not found")
        }
    }

}

//MARK: Webservices Methods
extension FiveADayViewController {
    func getFiveADayDeals() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathFiveADayDeals, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                var importedObjects: [FiveADayDeal] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<FiveADayDeal>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                self.deals.removeAll()
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                    self.deals.append(fetchedObject!)
                }
                
                if self.deals.isEmpty {
                    self.statefulView.showErrorViewWithRetry(errorMessage: "No Five A Day Deal Available", reloadMessage: "Tap To refresh")
                } else {
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                }
                
                self.pagerView.reloadData()
                self.pageControl.numberOfPages = self.deals.count
                
                if let firstDeals = self.deals.first {
                    self.viewedOffer(deal: firstDeals)
                }
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
    
    func getReloadStatus(cell: FiveADayCollectionViewCell, deal: FiveADayDeal, index: Int) {
        
        deal.showLoader = true
        self.pagerView.reloadData()

        let bar = deal.establishment.value
        let param = ["establishment_id" : bar!.id.value]
        
        self.reloadDataRequest = APIHelper.shared.hitApi(params: param, apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            deal.showLoader = false
            self.pagerView.reloadData()
            
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
                
                let redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemInfoDict)!
                redeemInfo.canReload = true
                
                let credit = redeemInfoDict["credit"] as! Int
                Utility.shared.userCreditUpdate(creditValue: credit)
                
                let redeemedCount = redeemInfoDict["redeemed_count"] as! Int
                if redeemedCount < 2 {
                    let redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemInfoDict)!
                    
                    var canReload = false
                    if !redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds == 0 {
                        canReload = true
                    }
                    self.redeemWithUserCredit(credit: credit, index: index, canReload: canReload)
                } else {
                    self.showCustomAlert(title: "Alert", message: "You have Redeemed your daily limit for this Bar.\nDon’t worry, come again tomorrow to Redeem more")
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }

    //viewOffer
    func viewedOffer(deal: FiveADayDeal) {
        
        guard self.canSendStats else {
            debugPrint("Cannot send stats")
            return
        }
        
        let params: [String: Any] = ["value": deal.id.value,
                                     "type":"offer_view"]
        
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
                debugPrint("view has been updated successfully: \(deal.title.value)")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericerror while view api : \(genericError.localizedDescription)")
            }
        }
    }
    
}


//MARK: FiveADayCollectionViewCellDelegate
extension FiveADayViewController: FiveADayCollectionViewCellDelegate {
    func fiveADayCell(cell: FiveADayCollectionViewCell, redeemedButtonTapped sender: UIButton) {
        
        self.pagerView.automaticSlidingInterval = 0.0
        
        let index = self.pagerView.index(for: cell)
        let deal = self.deals[index]
        if let bar = deal.establishment.value {
            if bar.canRedeemOffer.value {
                self.pagerView.automaticSlidingInterval = 0.0

                let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
                redeemStartViewController.deal = deal
                redeemStartViewController.delegate = self
                redeemStartViewController.selectedIndex = index
                redeemStartViewController.modalPresentationStyle = .overCurrentContext
                redeemStartViewController.redeemWithCredit = false
                self.present(redeemStartViewController, animated: true, completion: nil)
                
            } else {
                //get updated User Credit from server api and this deal establishment redeem count
                self.getReloadStatus(cell: cell, deal: deal, index: index)
            }
        } else {
            debugPrint("Bar not found")
        }
    }
    
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDetailButtonTapped sender: UIButton) {
        
        self.pagerView.automaticSlidingInterval = 0.0

        let index = self.pagerView.index(for: cell)
        let deal = self.deals[index]
        self.showDealDetail(deal: deal)
      
    }
    
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewBarDetailButtonTapped sender: UIButton) {

        self.pagerView.automaticSlidingInterval = 0.0

        let index = self.pagerView.index(for: cell)
        if let bar = self.deals[index].establishment.value {
            self.showBarDetail(bar: bar)
        } else {
            debugPrint("deals establishment value not found")
        }
    }
    
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDirectionButtonTapped sender: UIButton) {

        self.pagerView.automaticSlidingInterval = 0.0

        let index = self.pagerView.index(for: cell)
        if let bar = self.deals[index].establishment.value {
            self.showDirection(bar: bar)
        } else {
            debugPrint("deals establishment value not found")
        }
    }
    
    func fiveADayCell(cell: FiveADayCollectionViewCell, shareButtonTapped sender: UIButton) {
        let index = self.pagerView.index(for: cell)
        let deal = self.deals[index]
        
        deal.showSharingLoader = true
        self.pagerView.reloadData()
        self.pagerView.automaticSlidingInterval = 0.0
        
        Utility.shared.generateAndShareDynamicLink(deal: deal, controller: self, presentationCompletion: {
            deal.showSharingLoader = false
            self.pagerView.reloadData()
        }) {
            self.pagerView.automaticSlidingInterval = 4.0
        }
    }
}

//MARK: OutOfCreditViewControllerDelegate
extension FiveADayViewController: OutOfCreditViewControllerDelegate {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
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

//MARK: ReloadViewControllerDelegate
extension FiveADayViewController: ReloadViewControllerDelegate {
    func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

//MARK: InviteViewControllerDelegate
extension FiveADayViewController: InviteViewControllerDelegate {
    func inviteViewController(controller: InviteViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

//MARK: RedeemStartViewControllerDelegate
extension FiveADayViewController : RedeemStartViewControllerDelegate {
  
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0     
    }
    
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int, withCredit: Bool) {
        self.moveToRedeemDealViewController(withCredit: false, selectedIndex: selectedIndex)
    }
}

extension FiveADayViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {
        
        self.moveToRedeemDealViewController(withCredit: true, selectedIndex:selectedIndex)
    }
    
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

//MARK: Notification Methods
extension FiveADayViewController {
    
    @objc func reloadSuccessfullNotification(notification: Notification) {
        self.reloadData()
    }
}

//MARK: BarDetailViewControllerDelegate
extension FiveADayViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

//MARK: BarDetailViewControllerDelegate
extension FiveADayViewController: FiveADayDetailViewControllerDelegate {
    func fiveADayDetailViewController(controller: FiveADayDetailViewController, cancelButtonTapped sender: UIButton) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

//MARK: RedeemDealViewControllerDelegate
extension FiveADayViewController: RedeemDealViewControllerDelegate {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
    
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
       
        if error == nil {
            self.pagerView.reloadData()
        }

    }    
}


//MARK: CannotRedeemViewControllerDelegate
extension FiveADayViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}
