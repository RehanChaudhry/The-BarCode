//
//  OutOfCreditViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StoreKit

protocol OutOfCreditViewControllerDelegate: class {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int)
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton, selectedIndex: Int)
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int)
}

class OutOfCreditViewController: UIViewController {
    
    @IBOutlet weak var gradientTitleView: GradientView!

    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    @IBOutlet var unlimitedRedemptionButton: LoadingButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var reloadStackView: UIStackView!
    
    @IBOutlet var unlimitedRedemptionTop: NSLayoutConstraint!
    @IBOutlet var popupHeight: NSLayoutConstraint!
    
    var canReload: Bool = true
    var hasCredits: Bool = false
    var isOfferingUnlimitedRedemption: Bool = false
    var barId: String?
    
    weak var delegate: OutOfCreditViewControllerDelegate!

    var selectedIndex: Int = NSNotFound
    
    let productIdReload = bundleId + ".reload"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.hasCredits && self.canReload {

            self.inviteButton.isHidden = true
            self.reloadButton.isHidden = false
            self.unlimitedRedemptionButton.isHidden = true
            self.unlimitedRedemptionTop.constant = 0.0

            self.titleLabel.text = "Reload Now"
            self.detailLabel.text = "Reload now to use Credits and access all offers"

        } else if self.canReload {
            self.inviteButton.isHidden = false
            self.reloadButton.isHidden = false
            self.unlimitedRedemptionButton.isHidden = true
            self.unlimitedRedemptionTop.constant = 0.0

            self.detailLabel.text = "Reload now to access all offers and use credits. Get more credits by sharing offers or inviting friends"
        } else if self.isOfferingUnlimitedRedemption {
        
            self.reloadButton.isHidden = true
            self.inviteButton.isHidden = false
            self.unlimitedRedemptionButton.isHidden = false
            self.unlimitedRedemptionTop.constant = 16.0
            
            self.detailLabel.text = "This bar offers unlimited redemption. Pay £1.00 or ₹89.00 and you can redeem any offer till the bar closes. \n\nGet more credits by sharing offers or inviting friends"
            
        } else {
            self.reloadButton.isHidden = true
            self.inviteButton.isHidden = false
            self.unlimitedRedemptionButton.isHidden = true
            self.unlimitedRedemptionTop.constant = 0.0

            self.detailLabel.text = "Don’t worry, get more credits by sharing offers or inviting friends"
        }
    
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.popupHeight.constant = self.reloadStackView.frame.origin.y + self.reloadStackView.frame.size.height + 16.0
    }
    
    //MARK: IBActions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, closeButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, reloadButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
        
    }
    
    @IBAction func unlimitedRedemptionButtonTapped(sender: UIButton) {
        self.purchaseUnlimitedRedemption()
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, inviteButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
        
    }
    
    //MARK: Webservices Methods
    func purchaseUnlimitedRedemption() {
        guard let barId = self.barId else {
            self.showAlertController(title: "", msg: "Establishment info is not available. Please try later")
            return
        }
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.unlimitedRedemptionButton.showLoader()
        
        let productIdentifier = bundleId + ".unlimitedredemption"
        IAPHandler.shared.buyProductWithIdentifier(identifier: productIdentifier) { (transactionId, error) in
            
            guard error == nil else {
                debugPrint("Error while purchasing: \(error!.localizedDescription)")
                self.showAlertController(title: "", msg: error!.localizedDescription)
                self.unlimitedRedemptionButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            guard let transactionId = transactionId else {
                debugPrint("transactionId not avaiable")
                self.showAlertController(title: "", msg: "Transaction info not available")
                self.unlimitedRedemptionButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            debugPrint("transactionId: \(transactionId)")
            self.subscribeEstablishment(barId: barId, transactionId: transactionId)
        }
    }
    
    func subscribeEstablishment(barId: String, transactionId: String) {
        let params: [String : Any] = ["establishment_id" : barId,
                                      "token" : transactionId]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathEstablishmentSubscription, method: .post) { (response, serverError, error) in
            
            self.unlimitedRedemptionButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            func showRetryAlert(error: Error) {
                let alertController = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.unlimitedRedemptionButton.showLoader()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    self.subscribeEstablishment(barId: barId, transactionId: transactionId)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(retryAction)
                alertController.preferredAction = retryAction
                self.present(alertController, animated: true, completion: nil)
            }
            
            guard error == nil else {
                showRetryAlert(error: error!)
                return
            }
            
            guard serverError == nil else {
                showRetryAlert(error: serverError!.nsError())
                return
            }
            
            NotificationCenter.default.post(name: notificationNameUnlimitedRedemptionPurchased, object: barId)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
