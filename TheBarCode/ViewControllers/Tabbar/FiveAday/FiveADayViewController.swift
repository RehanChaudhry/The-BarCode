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

class FiveADayViewController: UIViewController {

    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var deals : [FiveADayDeal] = []
    
    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.deals = FiveADayDeal.getDummyList()
        
        self.pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.pageControl.numberOfPages = deals.count
        self.pagerView.isInfinite = true
        self.pageControl.currentPage = 0
        self.pagerView.automaticSlidingInterval = 4.0
        self.pagerView.backgroundColor = .clear
        self.pagerView.register(FiveADayCollectionViewCell.nib, forCellWithReuseIdentifier: FiveADayCollectionViewCell.reuseIdentifier)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.reloadData()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
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
    
    deinit {        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
    }
    
    //MARK: My Methods
    
    func reloadData() {
        self.dataRequest?.cancel()
        self.getFiveADayDeals()
    }
    
}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension FiveADayViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return false
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
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
}

//MARK: Webservices Methods
extension FiveADayViewController {
    func getFiveADayDeals() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathFiveADayDeals, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To Reload")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To Reload")
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
                    self.statefulView.showErrorViewWithRetry(errorMessage: "No Five A Day Deal Available", reloadMessage: "Tap To Refresh")
                } else {
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                }
                
                self.pagerView.reloadData()
                self.pageControl.numberOfPages = self.deals.count
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To Reload")
            }
        }
    }
}

//MARK: WebService Method
extension FiveADayViewController {
    func redeemFiveADayDeal(deal: FiveADayDeal, cell: FiveADayCollectionViewCell, redeemWithCredit: Bool) {
        
        self.pagerView.automaticSlidingInterval = 0.0
        UIApplication.shared.beginIgnoringInteractionEvents()
        cell.redeemButton.showLoader()
        
        let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.any
        
        let params: [String: Any] = ["establishment_id": deal.establishmentId.value,
                      "type": redeemType.rawValue,
                      "offer_id" : deal.id.value]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            self.pagerView.automaticSlidingInterval = 4.0
            cell.redeemButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error?.localizedDescription ?? genericErrorMessage)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError?.errorMessages() ?? genericErrorMessage)
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        let editedObject = transaction.edit(deal)
                        editedObject!.establishment.value!.canRedeemOffer.value = false
                    })
                    
                    if redeemWithCredit {
                        Utility.shared.userCreditUpdate()
                    }
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertController(title: "", msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
}

extension FiveADayViewController: FiveADayCollectionViewCellDelegate {
    func fiveADayCell(cell: FiveADayCollectionViewCell, redeemedButtonTapped sender: UIButton) {
        let index = self.pagerView.index(for: cell)
        let deal = self.deals[index]
        if let bar = deal.establishment.value {
            if bar.canRedeemOffer.value {
                self.pagerView.automaticSlidingInterval = 0.0

                let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
                redeemStartViewController.deal = deal
                redeemStartViewController.delegate = self
                redeemStartViewController.modalPresentationStyle = .overCurrentContext
                redeemStartViewController.redeemWithCredit = false
                self.present(redeemStartViewController, animated: true, completion: nil)
                
                
               // self.redeemFiveADayDeal(deal: deal, cell: cell, redeemWithCredit: false)
            } else {
                if bar.credit.value > 0 {
                    self.pagerView.automaticSlidingInterval = 0.0
                    let creditConsumptionController = self.storyboard?.instantiateViewController(withIdentifier: "CreditCosumptionViewController") as! CreditCosumptionViewController
                    creditConsumptionController.delegate = self
                    creditConsumptionController.modalPresentationStyle = .overCurrentContext
                    creditConsumptionController.selectedIndex = index
                    self.present(creditConsumptionController, animated: true, completion: nil)
                    
                    
                } else {
                    self.pagerView.automaticSlidingInterval = 0.0
                    let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
                    outOfCreditViewController.delegate = self
                    outOfCreditViewController.modalPresentationStyle = .overCurrentContext
                    outOfCreditViewController.selectedIndex = index
                    self.present(outOfCreditViewController, animated: true, completion: nil)
                }
            }
        } else {
            debugPrint("Bar not found")
        }
    }
    
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDetailButtonTapped sender: UIButton) {
        let index = self.pagerView.index(for: cell)
        
        let fiveADayDetailViewController = (self.storyboard?.instantiateViewController(withIdentifier: "FiveADayDetailViewController") as! FiveADayDetailViewController)
        fiveADayDetailViewController.modalPresentationStyle = .overCurrentContext
        fiveADayDetailViewController.deal = self.deals[index]
        self.present(fiveADayDetailViewController, animated: true, completion: nil)
    }
}

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
    
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int) {
        self.pagerView.automaticSlidingInterval = 4.0
    }
}

extension FiveADayViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {
        
        guard selectedIndex != NSNotFound else {
            debugPrint("Index not found for deal redumtion")
            return
        }
        
        let cell = self.pagerView(self.pagerView, cellForItemAt: selectedIndex)
        let deal = self.deals[selectedIndex]
        self.redeemFiveADayDeal(deal: deal, cell: cell as! FiveADayCollectionViewCell, redeemWithCredit: true)
        
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
