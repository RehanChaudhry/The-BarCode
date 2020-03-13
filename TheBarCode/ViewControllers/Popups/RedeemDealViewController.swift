//
//  RedeemDealViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import FirebaseAnalytics

protocol RedeemDealViewControllerDelegate: class {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int)
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int)
}

class RedeemDealViewController: CodeVerificationViewController {

    @IBOutlet weak var gradientTitleView: GradientView!

    weak var delegate: RedeemDealViewControllerDelegate!

    var barId: String!
    var dealInfo: Deal!
    
    var standardOfferId: String!
    
    var offerType: OfferType!
    
//    var deal: Deal!
//    var bar: Bar! //for standard offer
    
    var redeemingType: RedeemType!
    
//    var redeemWithCredit: Bool = false
//    var type: OfferType = .unknown
    var selectedIndex: Int = NSNotFound

    var isRedeemingSharedOffer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        if type != .standard {
//            type = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
//        }
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34

    }
    
    func showAlertAndDismiss(msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (alert) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    //MARK: My IBActions
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        self.redeemDeal()
    }
    
    override func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.redeemDealViewController(controller: self, cancelButtonTapped: sender as! UIButton, selectedIndex: self.selectedIndex)
        }
    }
    

}


//MARK: WebService Method
extension RedeemDealViewController {
    func redeemDeal() {
        
        var params: [String: Any] = ["establishment_id" : self.barId!,
                                     "code" : self.hiddenField.text!,
                                     "type" : self.redeemingType.rawValue]
        if self.offerType == OfferType.standard {
            params["standard_offer_id"] = self.standardOfferId
            
            Analytics.logEvent(submitBartenderCode, parameters: ["offer_id" : self.standardOfferId])
            
        } else {
            params["offer_id"] = self.dealInfo.id.value
            
            Analytics.logEvent(submitBartenderCode, parameters: ["offer_id" : self.dealInfo.id.value])
            
            if let shareId = self.dealInfo.sharedId.value, self.isRedeemingSharedOffer {
                params["shared_id"] = shareId
            }
        }
       
        debugPrint("params: \(params)")
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.actionButton.showLoader()

        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.actionButton.hideLoader()
            
            guard error == nil else {
                self.hiddenField.becomeFirstResponder()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.hiddenField.becomeFirstResponder()
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                        let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), self.barId!))
                        for bar in bars {
                            bar.canRedeemOffer.value = false
                        }
                    })
                    
                    let msg = "Success! Offer Redeemed"
                    let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        
                        self.dismiss(animated: true) {
                            self.delegate.redeemDealViewController(controller: self, dealRedeemed: nil, selectedIndex: self.selectedIndex)
                        }
                        
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
                    
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertAndDismiss(msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertAndDismiss(msg: genericError.localizedDescription)
                self.delegate.redeemDealViewController(controller: self, dealRedeemed: genericError, selectedIndex: self.selectedIndex)
                
            }
        }
    }
}

