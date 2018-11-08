//
//  RedeemDealViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore


protocol RedeemDealViewControllerDelegate: class {
    func redeemDealViewController(controller: RedeemDealViewController, cancelButtonTapped sender: UIButton, selectedIndex: Int)
    func redeemDealViewController(controller: RedeemDealViewController, dealRedeemed error: NSError?, selectedIndex: Int)
}

class RedeemDealViewController: CodeVerificationViewController {

    weak var delegate: RedeemDealViewControllerDelegate!

    var deal : Deal!
    var bar: Bar! //for standard offer
    var redeemWithCredit: Bool! = false
    var type: OfferType = .unknown
    var selectedIndex: Int = NSNotFound

    var isRedeemingSharedOffer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if type != .standard {
            type = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
        }
      
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
        redeemDeal(redeemWithCredit: self.redeemWithCredit)
    }

}


//MARK: WebService Method
extension RedeemDealViewController {
    func redeemDeal(redeemWithCredit: Bool) {
        
        var params: [String: Any]!
        if self.type == .standard {
            
            let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.standard
            params = ["establishment_id": self.bar.id.value,
                                         "type": redeemType.rawValue,
                                         "code": self.hiddenField.text!]
            
        } else {
            let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.any
            
            params = ["establishment_id": deal.establishmentId.value,
                                         "type": redeemType.rawValue,
                                         "offer_id" : deal.id.value,
                                         "code": self.hiddenField.text!]
            
        }
        
        if let shareId = deal.sharedId.value, self.isRedeemingSharedOffer {
            params["shared_id"] = shareId
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.actionButton.showLoader()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.actionButton.hideLoader()
            
            guard error == nil else {
                self.showAlertAndDismiss(msg: error?.localizedDescription ?? genericErrorMessage)
                self.delegate.redeemDealViewController(controller: self, dealRedeemed: error! as NSError, selectedIndex: self.selectedIndex)
                return
            }
            
            guard serverError == nil else {
                self.showAlertAndDismiss(msg: serverError?.errorMessages() ?? genericErrorMessage)
                self.delegate.redeemDealViewController(controller: self, dealRedeemed: serverError!.nsError(), selectedIndex: self.selectedIndex)
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    if self.type == .standard {
                        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                            let editedObject = transaction.edit(self.bar)
                            editedObject!.canRedeemOffer.value = false
                        })
                    } else {
                        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                            let editedObject = transaction.edit(self.deal)
                            editedObject!.establishment.value!.canRedeemOffer.value = false
                        })
                    }
                    
                    
                    if redeemWithCredit {
                       // Utility.shared.userCreditConsumed()
                    }
             
                    let msg = responseObj["message"] as! String
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

