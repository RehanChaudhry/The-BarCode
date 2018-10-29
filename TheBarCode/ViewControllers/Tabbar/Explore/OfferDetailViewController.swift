//
//  OfferDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OfferDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var bottomViewBottom: NSLayoutConstraint!
    
    @IBOutlet var timerButton: UIButton!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var redeemButton: GradientButton!
    
    var images: [String] = []
    
    var deal: Deal!
    
    var offerType : OfferType = .unknown
    
    var redeemTimer: Timer?
    var remainingSeconds = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: OfferDetailTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.images = [deal.image.value]
       
        self.titleLabel.text = self.deal.title.value
        self.descriptionLabel.text = self.deal.subTitle.value
        
        self.setUpBottomView()

        self.viewOffer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewHeight = ((273.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        var headerFrame = self.headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = headerViewHeight
        self.headerView.frame = headerFrame
    }
    
    deinit {
        self.redeemTimer?.invalidate()
        self.redeemTimer = nil
    }
    
    //MARK: My Methods
    func setUpBottomView() {
        self.offerType = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
        if self.offerType == .bannerAds {
            self.redeemButton.isHidden = true
            self.timerButton.isHidden = true
            self.bottomViewBottom.constant = self.bottomView.frame.height
        } else {
            
            let currentDate = Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = serverTimeFormat
            
            let currentTime = dateFormatter.date(from: dateFormatter.string(from: currentDate))!
                

            let isDateInRange = currentDate.isDate(inRange: self.deal.startDate, toDate: self.deal.endDate, inclusive: true)
            
            let isTimeInRange = currentTime.isDate(inRange: self.deal.startTime, toDate: self.deal.endTime, inclusive: true)
            
            //Can redeem deal (With in date and time range)
            if isDateInRange && isTimeInRange {
                debugPrint("Show Redeem deal")
                self.bottomViewBottom.constant = 0.0
                
                self.redeemButton.isHidden = false
                self.timerButton.isHidden = true
                
            } else {
                
                self.redeemButton.isHidden = true
                self.timerButton.isHidden = false
                
                //Deal expired
                if Date().compare(self.deal.endDateTime) == .orderedDescending {
                    debugPrint("Deal expired")
                    self.bottomViewBottom.constant = self.bottomView.frame.height
                } else {
                    
                    //TODO: This logic needs to be updated
                    
                    dateFormatter.dateFormat = serverDateFormat
                    let todayDateString = dateFormatter.string(from: Date())
                    
                    dateFormatter.dateFormat = serverTimeFormat
                    let dealStartTime = dateFormatter.string(from: self.deal.startTime)
                    
                    let todayDealDateTimeString = todayDateString + " " + dealStartTime
                    
                    dateFormatter.dateFormat = serverDateTimeFormat
                    let todayDealDateTime = dateFormatter.date(from: todayDealDateTimeString)!
                    
                    if Date().compare(todayDealDateTime) == .orderedAscending {
                        self.remainingSeconds = Int(todayDealDateTime.timeIntervalSinceNow)
                    } else {
                        let nextDayDateTime = todayDealDateTime.addingTimeInterval(60.0 * 60.0 * 24.0)
                        self.remainingSeconds = Int(nextDayDateTime.timeIntervalSinceNow)
                    }
                    
                    if self.remainingSeconds > 0 {
                        self.startReloadTimer()
                    } else {
                        debugPrint("cannot start timer")
                    }
                }
                
                debugPrint("Hide Redeem deal")
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func startReloadTimer() {
        self.redeemTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateRedeemTimer(sender: sender)
        })
    }
    
    func updateRedeemTimer(sender: Timer) {

        if self.remainingSeconds > 0 {
            self.remainingSeconds -= 1
            UIView.performWithoutAnimation {
                self.timerButton.setTitle("Starts in \(Utility.shared.getFormattedRemainingTime(time: TimeInterval(self.remainingSeconds)))", for: .normal)
                self.timerButton.layoutIfNeeded()
            }
            
        } else {
            self.redeemTimer?.invalidate()
            self.setUpBottomView()
        }
        
    }
    
    //MARK: IBAction
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        
        let bar = self.deal.establishment.value!
        if bar.canRedeemOffer.value {
//            if self.offerType == .exclusive {
                //for exclusive
                let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
                redeemStartViewController.deal = self.deal
                redeemStartViewController.delegate = self
                redeemStartViewController.modalPresentationStyle = .overCurrentContext
                redeemStartViewController.redeemWithCredit = false
                self.present(redeemStartViewController, animated: true, completion: nil)

//            } else if self.offerType == .live {
//                //for live offer deals
//                redeemDeal(redeemWithCredit: false)
//            }

        } else {
            if bar.credit.value > 0 {
                let creditConsumptionController = self.storyboard?.instantiateViewController(withIdentifier: "CreditCosumptionViewController") as! CreditCosumptionViewController
                creditConsumptionController.delegate = self
                creditConsumptionController.modalPresentationStyle = .overCurrentContext
                self.present(creditConsumptionController, animated: true, completion: nil)
                
                
            } else {
                let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
                outOfCreditViewController.delegate = self
                outOfCreditViewController.modalPresentationStyle = .overCurrentContext
                self.present(outOfCreditViewController, animated: true, completion: nil)
            }
        }
    
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension OfferDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OfferDetailTableViewCell.self)
        cell.configCell(deal: self.deal)
        return cell
    }
    
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension OfferDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.images[indexPath.item])
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension OfferDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

extension OfferDetailViewController : RedeemStartViewControllerDelegate {
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int) {
        
        if self.offerType == .exclusive {
            //for exclusive
            let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
            redeemDealViewController.deal = self.deal
            redeemDealViewController.redeemWithCredit = false
            redeemDealViewController.modalPresentationStyle = .overCurrentContext
            self.present(redeemDealViewController, animated: true, completion: nil)
        } else {
            
        }        
    }
    
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int) {
    }
}


extension OfferDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {

        if self.offerType == .exclusive {
            //for exclusive
            let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
            redeemStartViewController.deal = self.deal
            redeemStartViewController.redeemWithCredit = true
            redeemStartViewController.delegate = self
            redeemStartViewController.modalPresentationStyle = .overCurrentContext
            self.present(redeemStartViewController, animated: true, completion: nil)
        } else if self.offerType == .live {
            //for live
            redeemDeal(redeemWithCredit: true)
        }
    }
    
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
}


extension OfferDetailViewController: OutOfCreditViewControllerDelegate {
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

//MARK: ReloadViewControllerDelegate
extension OfferDetailViewController: ReloadViewControllerDelegate {
    func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        
    }
}

//MARK: InviteViewControllerDelegate
extension OfferDetailViewController: InviteViewControllerDelegate{
    func inviteViewController(controller: InviteViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int) {
        
    }
}


//MARK: WebService Method
extension OfferDetailViewController {
    func redeemDeal(redeemWithCredit: Bool) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.redeemButton.showLoader()
        
        let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.any
        
        let params: [String: Any] = ["establishment_id" : deal.establishmentId.value,
                                     "type" : redeemType.rawValue,
                                     "offer_id" : deal.id.value]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            self.redeemButton.hideLoader()
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
                        let editedObject = transaction.edit(self.deal)
                        editedObject!.establishment.value!.canRedeemOffer.value = false
                    })
                    
                    if redeemWithCredit {
                        Utility.shared.userCreditConsumed()
                    }
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
                    
                    let msg = responseObj["message"] as! String
                    self.showAlertController(title: "", msg: msg)
                    
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
    
    //viewOffer
    func viewOffer() {
        
        let params: [String: Any] = ["value": self.deal.id.value,
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
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    debugPrint("servererror while view api : \(genericError.localizedDescription)")
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("servererror while view api : \(genericError.localizedDescription)")
                
            }
        }
    }
    
    
}
