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

let kProductIdReload = "com.cygnismedia.TheBarCode.reload"

@objc protocol ReloadViewControllerDelegate: class {
    @objc optional func reloadController(controller: ReloadViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

class ReloadViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    @IBOutlet var creditsLabel: UILabel!
    
    @IBOutlet weak var timerWithTextLabel: UILabel!
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: ReloadViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    
    var canReload: Bool = true
    
    var redeemInfo: RedeemInfo!

    //Timer
    var timer = Timer()
    var seconds = 0
    
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
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {(sender: UIButton) in
            
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.checkReloadStatus()
        
        let user = Utility.shared.getCurrentUser()
        self.creditsLabel.text = "\(user!.credit)"
        
        self.productIDs = [kProductIdReload]
        self.requestProductInfo()
        SKPaymentQueue.default().add(self)
        
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: In-APP
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: self.productIDs)
            let productRequest: SKProductsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        } else {
            debugPrint("cannot make payment")
        }
    }
    
    func buyProduct(_ product: SKProduct) {
        debugPrint("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    //MARK: My Methods
    func getAttributedTimerString(timer:String) -> NSMutableAttributedString {
        
        let font = UIFont.appRegularFontOf(size: 12.0)
        
        let attributesWhite: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.white]
        
        let attributesBlue: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.appBlueColor()]
        
        let description = "Available Credits: \n You are out of credit. You can reload previous offers after ."
        let text = NSMutableAttributedString(string: description, attributes: attributesWhite)
    
        let description1 = " \(timer) "
        let text1 = NSMutableAttributedString(string: description1, attributes: attributesBlue)
        
        let description2 = "."
        let text2 = NSMutableAttributedString(string: description2, attributes: attributesWhite)
        
        text.append(text1)
        text.append(text2)
        return text
        
    }

   /* func canTimerReload(redeemInfo: RedeemInfo) -> Bool {

       /* let redeemedDateString = redeemInfo.redeemDatetime!//"2018-10-03 00:00:00"
        let serverDateString = redeemInfo.currentServerDatetime! //"2018-10-09 00:00:00"
        
        let formater = DateFormatter()
        formater.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        
        let reloadDateTime = formater.date(from: redeemedDateString)
        let serverCurrentDateTime = formater.date(from: serverDateString)
        
        //Add 7 days to reload time
        var timeInterval = DateComponents()
        timeInterval.day = 7
        let reloadEndDateTime = Calendar.current.date(byAdding: timeInterval, to: reloadDateTime!)!
        debugPrint("reloadEndDateTime \(reloadEndDateTime)")
        
        //Difference
        let interval = reloadEndDateTime.timeIntervalSince(serverCurrentDateTime!)
        seconds = Int(interval)*/
        
        //let interval =  TimeInterval(redeemInfo.remainingSeconds!)
       // seconds = Int(interval)
       // return (Utility.shared.checkTimerEnd(time:interval))
      
    }*/
    
    
    func checkTimer() {
        
        if ReedeemInfoManager.shared.redeemInfo!.canShowTimer() {
            //Run Timer
            self.seconds = ReedeemInfoManager.shared.redeemInfo?.remainingSeconds! ?? 0
            runTimer()
        } else {
            //Timer finished
            self.timerWithTextLabel.attributedText = getAttributedTimerString(timer: "00 : 00  : 00 : 00")
        }
    }
    
    //MARK: My IBActions
    @IBAction func reloadButtonTapped(_ sender: Any) {
        
        if !canReload {
            let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
            cannotRedeemViewController.messageText = "All your deals are already unlocked. You cannot reload please redeem first."
            cannotRedeemViewController.titleText = "Alert"
            cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
            self.present(cannotRedeemViewController, animated: true, completion: nil)
        } else {
            //check if redeemed deal ko 1 week hogya hai?
            //if yes allow reload --> Allow in app purchase -> Hit subscription service after in app purchase
            //otherwise show timer
            //on tap show alert you cannot redeem these deals at this time try after
            
            if ReedeemInfoManager.shared.redeemInfo!.canShowTimer() { //Timer finished
                if self.products.count > 0 {
                    //can reload API
                    self.buyProduct(self.products.first!)
                } else {
                    debugPrint("product array count zero")
                }
            } else {
                //Timer Running show Error
                let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
                cannotRedeemViewController.messageText = "you cannot reload deals at this time try after timer finished."
                cannotRedeemViewController.titleText = "Alert"
                cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
            }
        }
        
        //self.dismiss(animated: true, completion: nil)
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
    func checkReloadStatus() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        self.dataRequest = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To Reload")
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload
                    
                    ReedeemInfoManager.shared.canReload = false
                    self.canReload = ReedeemInfoManager.shared.canReload
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                    
                } else {
                    self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To Reload")
                }

                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                
//
//                self.redeemInfo = Mapper<RedeemInfo>().map(JSON: responseReloadStatusDict)!
//
//                debugPrint("current servertimer \(self.redeemInfo .currentServerDatetime!)")
               
                ReedeemInfoManager.shared.canReload = true
                ReedeemInfoManager.shared.saveRedeemInfo(redeemDic: responseReloadStatusDict)
                
                self.checkTimer()
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
    
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To Reload")
            }
            
        }
    }
    
    func reloadRedeems(transactionID: String) {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let params: [String:Any] = ["token": transactionID]
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathReload, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To Reload")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To Reload")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                //if yes allow reload --> Allow in app purchase -> Hit subscription service after in app purchase
                debugPrint("responseReloadStatusDict == \(responseReloadStatusDict)")
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                self.canReload = false
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To Reload")
            }
            
        }
    }
}



extension ReloadViewController {
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ReloadViewController.updateTimer)), userInfo: nil, repeats: true)
    }
        
    @objc func updateTimer() {
        seconds = ReedeemInfoManager.shared.updateRedeemInfo()
        if seconds < 0 {
            timer.invalidate()
        }
        let timerString = Utility.shared.timeString(time: TimeInterval(seconds))
        self.timerWithTextLabel.attributedText = getAttributedTimerString(timer:timerString)
    }
}


extension ReloadViewController : SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count != 0 {
            for product in response.products {
                products.append(product)
                debugPrint("product title == \(product.localizedTitle)")
                debugPrint("product desc == \(product.localizedDescription)")
                debugPrint("product price == \(product.priceLocale)")
            }
        } else {
            debugPrint("zero products fetched")
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            debugPrint("invalidate product identifier \(response.invalidProductIdentifiers.description)")
        }
        
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        debugPrint("Error Fetching product information")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        debugPrint("Received Payment Transaction Response from Apple");
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case .purchased:
                    debugPrint("Product Purchased");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    reloadRedeems(transactionID: trans.transactionIdentifier!)
                    break;
                case .failed:
                    debugPrint("Purchased Failed");
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case .restored:
                    debugPrint("Already Purchased");
                    SKPaymentQueue.default().restoreCompletedTransactions()
                default:
                    break;
                }
            }
        }
    }

}
