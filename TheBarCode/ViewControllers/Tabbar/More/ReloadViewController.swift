//
//  ReloadViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import HTTPStatusCodes
import Alamofire
import ObjectMapper
import StoreKit
import FirebaseAnalytics

let kProductIdReload = bundleId + ".reload"

@objc protocol ReloadViewControllerDelegate: class {
    @objc optional func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

enum ReloadState: String {
    case noOfferRedeemed, offerRedeemed, reloadTimerExpire, unKnown
}

class ReloadViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var creditsLabel: UILabel!
    @IBOutlet var reloadButton: GradientButton!
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: ReloadViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    var type: ReloadState! = .unKnown
    
    //In-app
    var transactionInProgress: Bool = false
    var productIDs: [String] = []
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Reload"
        
        // Do any additional setup after loading the view.
        //if not iphone5
        if !(UIScreen.main.bounds.size.height <= 568.0) {
            let coverHeight = ((239.0 / 315.0) * self.view.frame.width)
            var headerFrame = headerView.frame
            headerFrame.size.width = self.view.frame.width
            headerFrame.size.height = coverHeight + 100.0
            headerView.frame = headerFrame
        }

        
        self.view.backgroundColor = UIColor.appBgGrayColor()
        self.headerView.backgroundColor = UIColor.clear
        
        self.creditsLabel.layer.borderColor = UIColor.appGradientGrayStart().cgColor
        
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.register(cellType: ReloadPriceTVC.self)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.tableView.addSubview(self.statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.getReloadStatus()
        }
        
        self.getReloadStatus()
        
        self.productIDs = [kProductIdReload]
        SKPaymentQueue.default().add(self)
        
        Analytics.logEvent(viewReloadScreen, parameters: nil)
    }

    deinit {
        SKPaymentQueue.default().remove(self)
        
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.statefulView.frame = self.view.bounds
    }
    
    //MARK: In-APP
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            
            self.reloadButton.showLoader()
            UIApplication.shared.beginIgnoringInteractionEvents()
            
            let productIdentifiers = NSSet(array: self.productIDs)
            let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            self.showAlertController(title: "In App Purchase", msg: "Currently this device is not authorized to make payments. Please check your payment authorization settings and try again")
            debugPrint("cannot make payment")
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        debugPrint("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    //MARK: My Methods
    
    func setUpRedeemInfoView(type: ReloadState) {
        
        let user = Utility.shared.getCurrentUser()
        self.creditsLabel.text = "\(user!.credit)"
        
        self.type = type
        
        self.tableView.reloadData()
       
        if type == .noOfferRedeemed {
            
            let boldAttributes = [NSAttributedStringKey.font: UIFont.appBoldFontOf(size: 18.0),
                                  NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let attributedTitle = NSAttributedString(string: "You Are Fully Loaded!\n", attributes: boldAttributes)
            
            let boldSubTitleAttributes = [NSAttributedStringKey.font: UIFont.appRegularFontOf(size: 15.0),
                                          NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let attributedSubTitle = NSAttributedString(string: "You can start using all offers and credits now.", attributes: boldSubTitleAttributes)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedTitle)
            finalAttributedString.append(attributedSubTitle)
            
            self.titleLabel.attributedText = finalAttributedString
            
            self.reloadButton.setTitle("Reload", for: .normal)
                        
        } else if type == .offerRedeemed {
            
            guard let redeemInfo = self.redeemInfo else {
                debugPrint("Redeem info unavailable")
                return
            }
            
            let remainingTime = Utility.shared.getFormattedRemainingTime(time: TimeInterval(redeemInfo.remainingSeconds))
            
            let boldAttributes = [NSAttributedStringKey.font: UIFont.appBoldFontOf(size: 18.0),
                                  NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let blueAttributes = [NSAttributedStringKey.font: UIFont.appBoldFontOf(size: 20.0),
                                  NSAttributedStringKey.foregroundColor: UIColor.appBlueColor()]
            
            let attributedTimePrefix = NSAttributedString(string: "Reload all offers in ", attributes: boldAttributes)
            let attributedTime = NSAttributedString(string: remainingTime, attributes: blueAttributes)

            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedTimePrefix)
            finalAttributedString.append(attributedTime)
            
            self.titleLabel.attributedText = finalAttributedString
            
            UIView.performWithoutAnimation {
                self.reloadButton.setTitle("Reload In \(remainingTime)", for: .normal)
                self.reloadButton.layoutIfNeeded()
            }

            
        } else if type == .reloadTimerExpire {
            
            let boldAttributes = [NSAttributedStringKey.font: UIFont.appBoldFontOf(size: 18.0),
                                  NSAttributedStringKey.foregroundColor: UIColor.appBlueColor()]
            
            let attributedTitle = NSAttributedString(string: "Reload Now \n", attributes: boldAttributes)

            let boldSubTitleAttributes = [NSAttributedStringKey.font: UIFont.appBoldFontOf(size: 18.0),
                                          NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let attributedSubTitle = NSAttributedString(string: "0:00:00:00", attributes: boldSubTitleAttributes)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedTitle)
            finalAttributedString.append(attributedSubTitle)
            
            self.titleLabel.attributedText = finalAttributedString
            
            self.reloadButton.setTitle("Reload", for: .normal)
            
        } else {
            debugPrint("Unknown reload state")
        }
    }
    
    func startReloadTimer() {
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
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
            self.setUpRedeemInfoView(type: .offerRedeemed)
        } else {
            self.reloadTimer?.invalidate()
            self.setUpRedeemInfoView(type: .reloadTimerExpire)
        }
        
    }
    
    func showCustomAlert(title: String, message: String) {
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = message
        cannotRedeemViewController.titleText = title
        cannotRedeemViewController.headerImageName = "login_intro_reload_5"
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        self.present(cannotRedeemViewController, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    @IBAction func reloadButtonTapped(_ sender: Any) {
        
        Analytics.logEvent(reloadButtonClick, parameters: nil)
        
        if self.type == ReloadState.noOfferRedeemed {
            
            self.showCustomAlert(title: "You Are Already Fully Loaded", message: "You can use all available offers and credits now. Reload again in 7 days.")
            
        } else if self.type == ReloadState.offerRedeemed {
           
            self.showCustomAlert(title: "Reload Now", message: "Reload when the timer hits zero")
            
        } else if self.type == ReloadState.reloadTimerExpire {
           
            self.requestProductInfo()
            
        } else {
            debugPrint("Unknown reload state")
        }
    }
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true) {
            self.delegate?.reloadController?(controller: self, cancelButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }

}

extension ReloadViewController: UITableViewDelegate, UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ReloadPriceTVC.self)
        cell.setUpCell(state: self.type)
        return cell
    }
}

//MARK: Webservices Methods
extension ReloadViewController {
    func getReloadStatus() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        self.dataRequest = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")

                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                
                let credit = responseReloadStatusDict["credit"] as! Int
                Utility.shared.userCreditUpdate(creditValue: credit)
                
                self.redeemInfo = Mapper<RedeemInfo>().map(JSON: responseReloadStatusDict)!
               
                if self.redeemInfo!.isFirstRedeem {
                    self.setUpRedeemInfoView(type: .noOfferRedeemed)
                } else if !self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds == 0 {
                    self.setUpRedeemInfoView(type: .reloadTimerExpire)
                } else if !self.redeemInfo!.isFirstRedeem && self.redeemInfo!.remainingSeconds > 0 {
                    self.startReloadTimer()
                    self.setUpRedeemInfoView(type: .offerRedeemed)
                }
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
    
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
            
        }
    }
    
    func reloadRedeems(transactionID: String) {
        
        let params: [String : Any] = ["token" : transactionID]
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathReload, method: .post) { (response, serverError, error) in
            
            self.reloadButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "Reload", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "Reload", msg: serverError!.errorMessages())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let reloadStatusDict = (responseDict?["data"] as? [String : Any]), let _ = reloadStatusDict["user"] as? [String : Any] {
                
                self.setUpRedeemInfoView(type: .noOfferRedeemed)
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil, userInfo: nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
            
        }
    }
}

//MARK: InApp Purchase
extension ReloadViewController : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if let product = response.products.first {
            debugPrint("product title == \(product.localizedTitle)")
            debugPrint("product desc == \(product.localizedDescription)")
            debugPrint("product price == \(product.priceLocale)")
            self.buyProduct(product)
        } else {
            self.reloadButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.showAlertController(title: "Reload", msg: "Unable to fetch product from itunes. Please try again.")
            debugPrint("zero products fetched")
        }

        if response.invalidProductIdentifiers.count != 0 {
            debugPrint("invalidate product identifier \(response.invalidProductIdentifiers.description)")
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Error Fetching product information")
        self.reloadButton.hideLoader()
        UIApplication.shared.endIgnoringInteractionEvents()
        self.showAlertController(title: "Reload", msg: error.localizedDescription)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        debugPrint("Received Payment Transaction Response from Apple");
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    debugPrint("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    reloadRedeems(transactionID: trans.transactionIdentifier!)
                    break;
                case .failed:
                    debugPrint("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    self.reloadButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlertController(title: "Reload", msg: trans.error?.localizedDescription ?? genericErrorMessage)
                    break;
                case .restored:
                    debugPrint("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()
                    
                    self.reloadButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                default:
                    break;
                }
            }
        }
    }

}

