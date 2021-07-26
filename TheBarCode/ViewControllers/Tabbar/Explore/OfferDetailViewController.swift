//
//  OfferDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import HTTPStatusCodes
import ObjectMapper
import Alamofire
import FirebaseAnalytics
import CoreLocation
import CoreStore

class OfferDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet var bottomViewBottom: NSLayoutConstraint!
    
    @IBOutlet var timerButton: GradientButton!
    
    @IBOutlet var bottomView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var redeemButton: GradientButton!
    
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var bookmarkLoader: UIActivityIndicatorView!
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    var images: [String] = []
    
    var bar: Bar!
    var deal: Deal!
    
    var offerType : OfferType = .unknown
    
    var redeemTimer: Timer?
    var remainingSeconds = 0
    
    var reloadDataRequest: DataRequest?

    var isSharedOffer: Bool = false
    var loadingShareController: Bool = false
    
    var isPresenting: Bool = false
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.isPresenting {
            let leftBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backBarButtonTapped(sender:)))
            self.navigationItem.leftBarButtonItem = leftBarButton
        }
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: OfferDetailTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.images = [deal.imageUrl.value]
       
        self.titleLabel.text = self.deal.subTitle.value.uppercased()
        self.descriptionLabel.text = self.deal.title.value
        
        self.setUpBottomView()
        self.updateBookmarkButton()

        self.shareButton.tintColor = UIColor.appGrayColor()
        if self.deal.canShare.value {
            if deal.showSharingLoader {
                self.shareButton.isHidden = true
                self.sharingLoader.startAnimating()
            } else {
                self.shareButton.isHidden = false
                self.sharingLoader.stopAnimating()
            }
        } else {
            self.shareButton.isHidden = true
        }
        
        self.viewedOffer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(unlimitedRedemptionDidPurchasedNotification(notif:)), name: notificationNameUnlimitedRedemptionPurchased, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        NotificationCenter.default.removeObserver(self, name: notificationNameUnlimitedRedemptionPurchased, object: nil)
    }
    
    //MARK: My Methods
    
    @objc func backBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setUpBottomView() {
    
        self.setUpRedeemButtonView()
        self.offerType = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
        if self.offerType == .bannerAds {
            self.redeemButton.isHidden = true
            self.timerButton.isHidden = true
            self.bottomViewBottom.constant = self.bottomView.frame.height
            
        } else {
            
            if self.deal.isVoucher.value {
                
                self.redeemButton.isHidden = false
                self.timerButton.isHidden = true
                self.bottomViewBottom.constant = 0.0

            } else  {
                /*
                 * for scheduled offers, server assign start date and time, end date and time at 6 am for the next day
                 * for e.g. till 5 Feb 2020 05:59am, offer validity date time are
                 *     start date time: 4 Feb 2020, 06:01am
                 *     end date time: 5 Feb 2020, 05:59am
                 * to get start date as server, we need to convert device to server time zone (london) and subtract 6 hours
                 * for e.g. at 5 Feb 2020 10:59am (Pak Time), server time is 5 Feb 2020 05:59am
                 *     date considered at server is: 5 Feb 2020 05:59am - 6 hours = 4 Feb 2020 (11:59pm)
                 * */
                        
                let status = self.deal.getCurrentStatus()
                        
                switch status.status {
                case .notStarted:
                    self.remainingSeconds = self.deal.getStartsInRemainingSeconds()
                    self.startRedeemTimer()
                            
                    self.redeemButton.isHidden = true
                    self.timerButton.isHidden = false
                        
                case .started:
                    self.bottomViewBottom.constant = 0.0
                            
                    self.redeemButton.isHidden = false
                    self.timerButton.isHidden = true
                            
                case .expired:
                    self.bottomViewBottom.constant = self.bottomView.frame.height
                       
                    self.redeemButton.isHidden = true
                    self.timerButton.isHidden = false
                      
                    UIView.performWithoutAnimation {
                        self.timerButton.setTitle("Expired", for: .normal)
                        self.timerButton.layoutIfNeeded()
                    }
                }
                     
                debugPrint("Deal status: \(status.status)")
                debugPrint("Deal status reason: \(status.statusReason)")
                debugPrint("\n\n\n\n")
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func startRedeemTimer() {
        self.redeemTimer?.invalidate()
        self.redeemTimer = nil
        self.redeemTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateRedeemTimer()
        })
        RunLoop.current.add(self.redeemTimer!, forMode: .commonModes)
        self.updateRedeemTimer()
    }

    func updateRedeemTimer() {
        if self.remainingSeconds > 0 {
            self.remainingSeconds -= 1
            UIView.performWithoutAnimation {
                self.timerButton.setTitle("Starts in \(Utility.shared.getFormattedRemainingTime(time: TimeInterval(self.remainingSeconds)))", for: .normal)
                self.timerButton.layoutIfNeeded()
            }

        } else {
            self.redeemTimer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.setUpBottomView()
            }
        }

    }
    
    func setUpRedeemButtonView() {
        
        guard let bar = self.deal.establishment.value else {
            debugPrint("Establishment info not found")
            return
        }
        
        if self.deal.isVoucher.value {
            self.redeemButton.updateColor(withGrey: false)
            self.timerButton.updateColor(withGrey: false)
            
        } else if bar.canRedeemOffer.value || bar.currentlyUnlimitedRedemptionAllowed {
            self.redeemButton.updateColor(withGrey: false)
            self.timerButton.updateColor(withGrey: false)
        } else {
            self.redeemButton.updateColor(withGrey: true)
            self.timerButton.updateColor(withGrey: true)
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
            outOfCreditViewController.isOfferingUnlimitedRedemption = self.deal.establishment.value?.currentlyUnlimitedRedemptionAllowed ?? false
            outOfCreditViewController.barId = self.deal.establishmentId.value
            outOfCreditViewController.delegate = self
            outOfCreditViewController.modalPresentationStyle = .overCurrentContext
            self.present(outOfCreditViewController, animated: true, completion: nil)
        }
    }
    
    func showDirection(bar: Bar) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
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
    
    func updateBookmarkButton() {
        
        if self.deal.isVoucher.value  {
            self.bookmarkButton.isHidden = true

        } else if self.deal.savingBookmarkStatus {
            self.bookmarkButton.isHidden = true
            self.bookmarkLoader.startAnimating()
        } else {
            
            if self.deal.isBookmarked.value {
                self.bookmarkButton.tintColor = UIColor.appBlueColor()
            } else {
                self.bookmarkButton.tintColor = UIColor.appGrayColor()
            }
            
            self.bookmarkButton.isHidden = false
            self.bookmarkLoader.stopAnimating()
        }
    }
    
    func updateShareButtonState() {
        if self.deal.showSharingLoader {
            self.shareButton.isHidden = true
            self.sharingLoader.startAnimating()
        } else {
            self.shareButton.isHidden = false
            self.sharingLoader.stopAnimating()
        }
    }
    
    func showRedeemStartViewController(redeemType: RedeemType) {
        let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.offerType = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
        redeemStartViewController.delegate = self
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        redeemStartViewController.redeemingType = redeemType
        redeemStartViewController.isRedeemingSharedOffer = self.isSharedOffer
        redeemStartViewController.barId = self.deal.establishmentId.value
        redeemStartViewController.dealInfo = self.deal
        self.present(redeemStartViewController, animated: true, completion: nil)
    }
        
    //MARK: IBAction
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        
        Analytics.logEvent(redeemOfferButtonClick, parameters: ["offer_id" : self.deal.id.value])
        
        guard let bar = self.deal.establishment.value else {
            debugPrint("Establishment info not found")
            return
        }
            
        if self.deal.isVoucher.value {
            self.showRedeemStartViewController(redeemType: RedeemType.voucher)
        } else if bar.canRedeemOffer.value {
            self.showRedeemStartViewController(redeemType: RedeemType.any)
        } else if bar.canDoUnlimitedRedemption.value && bar.currentlyUnlimitedRedemptionAllowed {
            self.showRedeemStartViewController(redeemType: RedeemType.unlimitedReload)
        } else {
            //get updated User Credit from server api and this establishment redeem count
            self.getReloadStatus()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.updateBookmarkStatus(offer: self.deal, isBookmarked: !self.deal.isBookmarked.value)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        self.loadingShareController = true
        
        self.deal.showSharingLoader = true
        self.updateShareButtonState()
        
        Utility.shared.generateAndShareDynamicLink(deal: self.deal, controller: self, presentationCompletion: {
            self.deal.showSharingLoader = false
            self.updateShareButtonState()
            self.loadingShareController = false
        }) {
            
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension OfferDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OfferDetailTableViewCell.self)
        cell.delegate = self
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
        cell.setUpCell(imageName: self.images[indexPath.item], deal: self.deal, currencySymbol: self.bar.currencySymbol.value)
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension OfferDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}

//MARK: RedeemStartViewControllerDelegate
extension OfferDetailViewController: RedeemStartViewControllerDelegate {
   
    func redeemStartViewController(controller: RedeemStartViewController, redeemStatus successful: Bool, selectedIndex: Int) {
        
        if successful {
            if self.deal.isVoucher.value {
                NotificationCenter.default.post(name: notificationNameRefreshExclusive, object: nil)

                if self.isPresenting {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
              
            }
            self.setUpBottomView()
        }
    }
    
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int) {
     }
    
  /*  func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int, redeemType: RedeemType) {
        let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
        redeemDealViewController.isRedeemingSharedOffer = self.isSharedOffer
        redeemDealViewController.barId = self.deal.establishmentId.value
        redeemDealViewController.dealInfo = self.deal
        redeemDealViewController.redeemingType = redeemType
        redeemDealViewController.delegate = self
        redeemDealViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemDealViewController, animated: true, completion: nil)
    }*/
}

//MARK: CreditCosumptionViewControllerDelegate
extension OfferDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {
        self.showRedeemStartViewController(redeemType: RedeemType.credit)
    }
    
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
}

//MARK: OutOfCreditViewControllerDelegate
extension OfferDetailViewController: OutOfCreditViewControllerDelegate {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
 
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton, selectedIndex: Int) {
        let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
        reloadNavigation.modalPresentationStyle = .fullScreen
        
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        reloadController.shouldAutoDismissOnReload = true
        reloadController.delegate = self
        reloadController.selectedIndex = selectedIndex
        self.present(reloadNavigation, animated: true, completion: nil)
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int) {
        let inviteNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "InviteNavigation") as! UINavigationController)
        inviteNavigation.modalPresentationStyle = .fullScreen
        
        let inviteController =  inviteNavigation.viewControllers.first as! InviteViewController
        inviteController.isDismissable = true
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
    //viewOffer
    func viewedOffer() {
        
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
        
        self.redeemButton.showLoader()
        let bar = self.deal.establishment.value
        let param = ["establishment_id" : bar!.id.value]

        self.reloadDataRequest = APIHelper.shared.hitApi(params: param , apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            self.redeemButton.hideLoader()
            
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
                let barIsOfferingUnlimitedRedemption = self.deal.establishment.value?.currentlyUnlimitedRedemptionAllowed ?? false
                if redeemedCount < 2 || barIsOfferingUnlimitedRedemption {
                    
                    let redeemInfo = Mapper<RedeemInfo>().map(JSON: redeemInfoDict)!
                    
                    var canReload = false
                    if !redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds == 0 {
                        canReload = true
                    }
                    
                    self.redeemWithUserCredit(credit: credit, canReload: canReload)
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

    func updateBookmarkStatus(offer: Deal, isBookmarked: Bool) {
        
        guard !offer.savingBookmarkStatus else {
            debugPrint("Already saving bookmark status")
            return
        }
        
        offer.savingBookmarkStatus = true
        
        self.updateBookmarkButton()
        
        let offerId: String = offer.id.value
        
        let params: [String : Any] = ["offer_id" : offerId,
                                      "is_favorite" : isBookmarked]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddRemoveBookmarkedOffer, method: .put) { (response, serverError, error) in
            
            offer.savingBookmarkStatus = false
            
            defer {
                self.updateBookmarkButton()
            }
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark offer status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while saving bookmark offer status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedOffer = transaction.edit(offer)
                edittedOffer?.isBookmarked.value = isBookmarked
            })
            
            if isBookmarked {
                NotificationCenter.default.post(name: notificationNameBookmarkAdded, object: offer)
            } else {
                NotificationCenter.default.post(name: notificationNameBookmarkRemoved, object: offer)
            }
        }
    }
}

/*
//MARK: RedeemDealViewControllerDelegate
extension OfferDetailViewController: RedeemDealViewControllerDelegate {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
    
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int) {
        
        if error == nil {
            self.setUpRedeemButtonView()
        }
    }
}*/

//MARK: OfferDetailTableViewCellDelegate
extension OfferDetailViewController: OfferDetailTableViewCellDelegate{
    func OfferDetailCell(cell: OfferDetailTableViewCell, viewDirectionButtonTapped sender: UIButton) {
       
        let bar =  self.deal.establishment.value
        self.showDirection(bar: bar!)
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension OfferDetailViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton, cartType: Bool) {
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}

//MARK: Notification Methods
extension OfferDetailViewController {
    @objc func unlimitedRedemptionDidPurchasedNotification(notif: Notification) {
        if let bar = self.deal.establishment.value, let barId = notif.object as? String, bar.id.value == barId {
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedEstablishment = transaction.edit(bar)
                editedEstablishment?.canDoUnlimitedRedemption.value = true
            })
            
            self.setUpRedeemButtonView()
        }
    }
}
