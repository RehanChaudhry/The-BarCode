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

let kProductIdReload = bundleId + ".reload"

@objc protocol ReloadViewControllerDelegate: class {
    @objc optional func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

enum ReloadState: String {
    case noOfferRedeemed, offerRedeemed, reloadTimerExpire
}

class ReloadViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    @IBOutlet var creditsLabel: UILabel!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var reloadButton: GradientButton!
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: ReloadViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    var type: ReloadState!
    
    //In-app
    var transactionInProgress: Bool = false
    var productIDs: [String] = []
    var products: [SKProduct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let coverHeight = ((249.0 / 375.0) * self.view.frame.width)
        var headerFrame = headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = coverHeight + 100.0
        headerView.frame = headerFrame
        
        self.view.backgroundColor = UIColor.appBgGrayColor()
        self.headerView.backgroundColor = UIColor.clear
        self.creditsLabel.layer.borderColor = UIColor.appGradientGrayStart().cgColor
        
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.tableView.addSubview(self.statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.getReloadStatus()
        }
        
        self.getReloadStatus()
        
        self.productIDs = [kProductIdReload]
        SKPaymentQueue.default().add(self)
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
        
        let font = UIFont.appRegularFontOf(size: 12.0)
        let attributesNormal: [NSAttributedStringKey: Any] = [.font: font,
            .foregroundColor: UIColor.white]
        
        if type == .noOfferRedeemed {
            let attributedTitle = NSAttributedString(string: "Available Credits: \nYou are eligible for redeem of all type of offer of any bar/establishment.", attributes: attributesNormal)
            self.titleLabel.attributedText = attributedTitle
        } else if type == .offerRedeemed {
            
            guard let redeemInfo = self.redeemInfo else {
                debugPrint("Redeem info unavailable")
                return
            }
            
            let timerAttributed: [NSAttributedStringKey: Any] = [
                .font: font,
                .foregroundColor: UIColor.appBlueColor()]
            
            let timerText = Utility.shared.getFormattedRemainingTime(time: TimeInterval(redeemInfo.remainingSeconds))
            
           
            if user!.credit > 0 {
              
                let finalText = "Available Credits: \nYou can reload all used offers in \(timerText)."
                
                let attributedTitle = NSMutableAttributedString(string: finalText, attributes: attributesNormal)
                attributedTitle.addAttributes(timerAttributed, range: (finalText as NSString).range(of: timerText))
                
                self.titleLabel.attributedText = attributedTitle
                
            } else {
                let text = "You are out of credits."
                let finalText = "\(text) \nYou can reload all used offers in \(timerText)"
                
                let attributedTitle = NSMutableAttributedString(string: finalText, attributes: attributesNormal)
                attributedTitle.addAttributes(timerAttributed, range: (finalText as NSString).range(of: timerText))
                
                let attributesBold: [NSAttributedStringKey: Any] =
                                    [.font: UIFont.appBoldFontOf(size: 12.0),
                                     .foregroundColor: UIColor.white]
                attributedTitle.addAttributes(attributesBold, range: (finalText as NSString).range(of: text))

                
                self.titleLabel.attributedText = attributedTitle
            }
            
        } else if type == .reloadTimerExpire {
            let attributedTitle = NSAttributedString(string: "Available Credits: \nCongrats you are able to reload.", attributes: attributesNormal)
            self.titleLabel.attributedText = attributedTitle
            
        } else {
            debugPrint("Unknown reload state")
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
            self.setUpRedeemInfoView(type: .offerRedeemed)
        } else {
            self.reloadTimer?.invalidate()
            self.setUpRedeemInfoView(type: .reloadTimerExpire)
        }
        
    }
    
    //MARK: My IBActions
    @IBAction func reloadButtonTapped(_ sender: Any) {
        
        if self.type == ReloadState.noOfferRedeemed {
            let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
            cannotRedeemViewController.messageText = "All your deals are already unlocked. You cannot reload please redeem first."
            cannotRedeemViewController.titleText = "Alert"
            cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
            self.present(cannotRedeemViewController, animated: true, completion: nil)
        } else if self.type == ReloadState.offerRedeemed {
            let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
            cannotRedeemViewController.messageText = "you cannot reload deals at this time try after timer finished."
            cannotRedeemViewController.titleText = "Alert"
            cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
            self.present(cannotRedeemViewController, animated: true, completion: nil)
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

extension ReloadViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
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
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload
                    
                    self.setUpRedeemInfoView(type: .noOfferRedeemed)
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                    
                } else {
                    self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
                }

                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                
                let credit = responseReloadStatusDict["credit"] as! Int
                Utility.shared.userCreditUpdate(creditValue: credit)
                
                self.redeemInfo = Mapper<RedeemInfo>().map(JSON: responseReloadStatusDict)!
                if self.redeemInfo!.remainingSeconds > 0 {
                    self.setUpRedeemInfoView(type: .offerRedeemed)
                    self.startReloadTimer()
                } else {
                    self.setUpRedeemInfoView(type: .reloadTimerExpire)
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
