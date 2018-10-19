//
//  RedeemStartViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class RedeemStartViewController: UIViewController {

    var presentedVC : UIViewController!
    
    var deal : Deal!

    var type: OfferType = .unknown
    var barId = ""
    
    var redeemWithCredit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func barTenderReadyButtonTapped(_ sender: Any) {
        presentedVC = self.presentingViewController
        
        self.dismiss(animated: true) {
            let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
            redeemDealViewController.deal = self.deal
            redeemDealViewController.redeemWithCredit = self.redeemWithCredit
            redeemDealViewController.modalPresentationStyle = .overCurrentContext
            self.presentedVC.present(redeemDealViewController, animated: true, completion: nil)

        }
    }
    
    @IBAction func takeMeBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: Webservices Methods
extension RedeemStartViewController {
    func barTenderRedeemDeal() {
        
        var params : [String : Any] = [:]
        if type == .standard {
             params = ["establishment_id" :  self.barId,
                        "type" : "standard"]
        } else {
            params = ["establishment_id" : self.deal.establishmentId.value,
                      "type" :"reload",
                      "offer_id" :self.deal.id.value ]
        }
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
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
                    //todo fetch establishment from establishment id than set flag 
                    
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        let editedObject = transaction.edit(self.deal)
                        editedObject!.establishment.value!.canRedeemOffer.value = false
                    })
                    
                    self.dismiss(animated: true, completion: nil)
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
