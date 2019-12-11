//
//  RedeemStartViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics

protocol RedeemStartViewControllerDelegate: class {
    func redeemStartViewController(controller: RedeemStartViewController, redeemButtonTapped sender: UIButton, selectedIndex: Int, redeemType: RedeemType)
    func redeemStartViewController(controller: RedeemStartViewController, backButtonTapped sender: UIButton, selectedIndex: Int)
}

class RedeemStartViewController: UIViewController {

    @IBOutlet weak var gradientTitleView: GradientView!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var bartenderLabel: UILabel!
    
    @IBOutlet weak var actionButton: GradientButton!
    
    @IBOutlet var standardOfferInfoLabel: UILabel!
    
    @IBOutlet var popupHeight: NSLayoutConstraint!
    
    @IBOutlet var takeMeBackButton: UIButton!
    
    weak var delegate: RedeemStartViewControllerDelegate!
    
    var selectedIndex: Int = NSNotFound

    var redeemingType: RedeemType!
    
    var offerType: OfferType!
    
//    var deal : Deal! //for all offers except standard
//    var type: OfferType = .unknown
//    var bar: Bar! //for standard offer
//
//    var redeemWithCredit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
  
       //self.setupInitialView()
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
        
        if self.redeemingType == RedeemType.unlimitedReload {
            self.standardOfferInfoLabel.text = "Unlimited Offer"
        } else {
            if self.offerType == OfferType.standard {
                self.standardOfferInfoLabel.text = "Discount applies only to the first £20.00"
            } else {
                self.standardOfferInfoLabel.text = ""
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.popupHeight.constant = self.takeMeBackButton.frame.origin.y + self.takeMeBackButton.frame.size.height + 16.0
    }
    
   /* func setupInitialView() {
       
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
    }*/

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
        
        Analytics.logEvent(bartenderReadyClick, parameters: nil)
        
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, redeemButtonTapped: sender, selectedIndex: self.selectedIndex, redeemType: self.redeemingType)
        }
    }
    
    @IBAction func takeMeBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, backButtonTapped: sender as! UIButton, selectedIndex: self.selectedIndex)
        }
    }
}
