//
//  RedeemDealViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

class RedeemDealViewController: CodeVerificationViewController {

    var deal : Deal!
    
    var redeemWithCredit: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func showAlertAndDismiss(msg: String){
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "", style: .cancel) { (alert) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    

    //MARK: My IBActions
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        //self.dismiss(animated: true, completion: nil)
        redeemDeal(redeemWithCredit: self.redeemWithCredit)
        
    }

}


//MARK: WebService Method
extension RedeemDealViewController {
    func redeemDeal(redeemWithCredit: Bool) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.any
        
        let params: [String: Any] = ["establishment_id": deal.establishmentId.value,
                                     "type": redeemType.rawValue,
                                     "offer_id" : deal.id.value,
                                     "code": self.hiddenField.text!]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()

            guard error == nil else {
                self.showAlertAndDismiss(msg: error?.localizedDescription ?? genericErrorMessage)
                return
            }
            
            guard serverError == nil else {
                self.showAlertAndDismiss(msg: serverError?.errorMessages() ?? genericErrorMessage)
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        let editedObject = transaction.edit(self.deal)
                        editedObject!.establishment.value!.canRedeemOffer.value = false
                    })
                    
                    self.dismiss(animated: true, completion: nil)
                    
                    if redeemWithCredit {
                        Utility.shared.userCreditConsumed()
                    }
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertAndDismiss(msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertAndDismiss(msg: genericError.localizedDescription)
            }
        }
    }
}

