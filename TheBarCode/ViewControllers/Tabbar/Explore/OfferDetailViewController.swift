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
    
    var images: [String] = []
    
    var deal: Deal!
    
    var offerType : OfferType = .unknown
    
    var redeemTimer: Timer?
    var remainingSeconds = 0
    
    var reloadDataRequest: DataRequest?

    var isSharedOffer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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

        self.viewedOffer()
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
    }
    
    //MARK: My Methods
    func setUpBottomView() {
        
        self.redeemButton.updateColor(withGrey: !self.deal.establishment.value!.canRedeemOffer.value)
        self.timerButton.updateColor(withGrey: !self.deal.establishment.value!.canRedeemOffer.value)
        
        self.setUpRedeemButtonView()
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
            
            let dealStartTime = dateFormatter.date(from: dateFormatter.string(from: self.deal.startDateTime))!
            let dealEndTime = dateFormatter.date(from: dateFormatter.string(from: self.deal.endDateTime))!
            
            let isDateInRange = currentDate.isDate(inRange: self.deal.startDateTime, toDate: self.deal.endDateTime, inclusive: true)
            
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
                
                //Deal not started yet
                if Date().compare(self.deal.startDateTime) == .orderedAscending {
                    self.remainingSeconds = Int(self.deal.startDateTime.timeIntervalSince(Date())) + 1
                    self.startRedeemTimer()
                }
                
                //Deal expired
                else if Date().compare(self.deal.endDateTime) == .orderedDescending {
                    debugPrint("Deal expired")
                    self.bottomViewBottom.constant = self.bottomView.frame.height
                } else {
                    
                    //TODO: This logic needs to be updated
                    
                    dateFormatter.dateFormat = serverDateFormat
                    let todayDateString = dateFormatter.string(from: Date())
                    
                    dateFormatter.dateFormat = serverTimeFormat
                    let dealStartTime = dateFormatter.string(from: dealStartTime)
                    
                    let todayDealDateTimeString = todayDateString + " " + dealStartTime
                    
                    dateFormatter.dateFormat = serverDateTimeFormat
                    let todayDealDateTime = dateFormatter.date(from: todayDealDateTimeString)!
                    
                    if Date().compare(todayDealDateTime) == .orderedAscending {
                        self.remainingSeconds = Int(todayDealDateTime.timeIntervalSinceNow) + 1
                    } else {
                        let nextDayDateTime = todayDealDateTime.addingTimeInterval(60.0 * 60.0 * 24.0)
                        self.remainingSeconds = Int(nextDayDateTime.timeIntervalSinceNow) + 1
                    }
                    
                    if self.remainingSeconds > 0 {
                        self.startRedeemTimer()
                    } else {
                        debugPrint("cannot start timer")
                    }
                }
                
                debugPrint("Hide Redeem deal")
            }
        }
        
        self.view.layoutIfNeeded()
    }
    
    func startRedeemTimer() {
        self.redeemTimer?.invalidate()
        self.redeemTimer = nil
        self.redeemTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateRedeemTimer(sender: sender)
        })
        RunLoop.current.add(self.redeemTimer!, forMode: .commonModes)
        self.updateRedeemTimer(sender: self.redeemTimer!)
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
    
    func moveToRedeemDealViewController(withCredit: Bool){
        let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
        redeemDealViewController.isRedeemingSharedOffer = self.isSharedOffer
        redeemDealViewController.deal = self.deal
        redeemDealViewController.redeemWithCredit = withCredit
        redeemDealViewController.delegate = self
        redeemDealViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemDealViewController, animated: true, completion: nil)
    }
    
    func moveToRedeemStartViewController(withCredit: Bool){
        
        let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.deal = self.deal
        redeemStartViewController.delegate = self
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        redeemStartViewController.redeemWithCredit = withCredit
        self.present(redeemStartViewController, animated: true, completion: nil)
    }
    
    func setUpRedeemButtonView() {
        let bar = self.deal.establishment.value
        if !bar!.canRedeemOffer.value {
            self.redeemButton.updateColor(withGrey: true)
        } else {
            self.redeemButton.updateColor(withGrey: false)
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
    
    func showDirection(bar: Bar) {
        let user = Utility.shared.getCurrentUser()!

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let source = CLLocationCoordinate2D(latitude: user.latitude.value, longitude: user.longitude.value)
            
            let urlString = String(format: "comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",source.latitude,source.longitude,bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
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
        if self.deal.savingBookmarkStatus {
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
    
    //MARK: IBAction
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        
        Analytics.logEvent(redeemOfferButtonClick, parameters: nil)
        
        let bar = self.deal.establishment.value!
        if bar.canRedeemOffer.value {

            let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
            redeemStartViewController.deal = self.deal
            redeemStartViewController.delegate = self
            redeemStartViewController.modalPresentationStyle = .overCurrentContext
            redeemStartViewController.redeemWithCredit = false
            self.present(redeemStartViewController, animated: true, completion: nil)

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
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int, withCredit: Bool) {
        
        self.moveToRedeemDealViewController(withCredit: withCredit)
    }
    
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int) {
    }
}


extension OfferDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {

        self.moveToRedeemStartViewController(withCredit: true)
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
                if redeemedCount < 2 {
                    
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
            
            try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
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

//MARK: RedeemDealViewControllerDelegate
extension OfferDetailViewController: RedeemDealViewControllerDelegate {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int) {
    }
    
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int) {
        
        if error == nil {
            self.setUpRedeemButtonView()
        }
    }
}

//MARK: OfferDetailTableViewCellDelegate
extension OfferDetailViewController: OfferDetailTableViewCellDelegate{
    func OfferDetailCell(cell: OfferDetailTableViewCell, viewDirectionButtonTapped sender: UIButton) {
       
        let bar =  self.deal.establishment.value
        self.showDirection(bar: bar!)
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension OfferDetailViewController: CannotRedeemViewControllerDelegate {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        
    }
}
