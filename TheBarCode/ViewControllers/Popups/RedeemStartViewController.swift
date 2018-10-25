//
//  RedeemStartViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

protocol RedeemStartViewControllerDelegate: class {
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int)
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int)
}

class RedeemStartViewController: UIViewController {

    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var bartenderLabel: UILabel!
    
    @IBOutlet weak var actionButton: GradientButton!
    
    weak var delegate: RedeemStartViewControllerDelegate!
    
    var selectedIndex: Int = NSNotFound

    var deal : Deal! //for all offers except standard

    var type: OfferType = .unknown
    var bar: Bar! //for standard offer
    
    var redeemWithCredit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if type == .standard {
            detailLabel.text = "Are you sure you would like to redeem this deal?"
            actionButton.setTitle("Redeem deal", for: .normal)
            bartenderLabel.isHidden = true
        } else {
            type = Utility.shared.checkDealType(offerTypeID: self.deal.offerTypeId.value)
            
            if type == .exclusive {
                
                detailLabel.text = "Is the bartender ready? They will need to enter secret BarCode to activate this deal."
                actionButton.setTitle("Bartender Ready", for: .normal)
                bartenderLabel.isHidden = false
            } else {
                detailLabel.text = "Are you sure you would like to redeem this deal?"
                actionButton.setTitle("Redeem deal", for: .normal)
                bartenderLabel.isHidden = true
            }
        }
       
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
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, backButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }
    
    @IBAction func barTenderReadyButtonTapped(_ sender: UIButton) {
        
        if type == .exclusive {
            self.dismiss(animated: true) {
                self.delegate.redeemStartViewController(controller: self, redeemButtonTapped: sender, selectedIndex: self.selectedIndex)
            }
        } else {
            self.barTenderRedeemDeal()
        }

        /*
        self.dismiss(animated: true) {
        let redeemDealViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemDealViewController") as! RedeemDealViewController)
        redeemDealViewController.deal = self.deal
        redeemDealViewController.redeemWithCredit = self.redeemWithCredit
        redeemDealViewController.modalPresentationStyle = .overCurrentContext
        self.presentedVC.present(redeemDealViewController, animated: true, completion: nil)
         
         */
    }
    
    @IBAction func takeMeBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, backButtonTapped: sender as! UIButton, selectedIndex: self.selectedIndex)
        }
    }
}


//MARK: Webservices Methods
extension RedeemStartViewController {
    func barTenderRedeemDeal() {
        
        var params : [String : Any] = [:]
        if type == .standard {
             params = ["establishment_id" :  self.bar.id.value,
                        "type" : "standard"]
        } else {
            params = ["establishment_id" : self.deal.establishmentId.value,
                      "type" :"reload",
                      "offer_id" :self.deal.id.value ]
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.actionButton.showLoader()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.actionButton.hideLoader()

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
                    
                    if self.deal != nil {
                        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                            let editedObject = transaction.edit(self.deal)
                            editedObject!.establishment.value!.canRedeemOffer.value = false
                        })
                    } else {
                        //standard handling
                        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                            let editedObject = transaction.edit(self.bar)
                            editedObject!.canRedeemOffer.value = false
                        })
                    }
                   
                    /*
                    if !ReedeemInfoManager.shared.canReload {
                        //Todo post notification from here to run timer
                        let notification = Notification.Name.checkReloadStatusNotification
                        NotificationCenter.default.post(name: notification, object: nil)
                    }*/
                    
                    
                    self.dismiss(animated: true) {
                        self.delegate.redeemStartViewController(controller: self, redeemButtonTapped: self.actionButton, selectedIndex: self.selectedIndex)
                    }
                    
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

