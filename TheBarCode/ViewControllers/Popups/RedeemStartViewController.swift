//
//  RedeemStartViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import CoreStore
import HTTPStatusCodes
import Alamofire

protocol RedeemStartViewControllerDelegate: class {    
    func redeemStartViewController(controller: RedeemStartViewController, redeemStatus successful: Bool, selectedIndex: Int)
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
    var locationManager: MyLocationManager!

//    var deal : Deal! //for all offers except standard
//    var type: OfferType = .unknown
//    var bar: Bar! //for standard offer
//
//    var redeemWithCredit: Bool = false
    
    var barId: String!
    var dealInfo: Deal!
    
    var standardOfferId: String!
    var isRedeemingSharedOffer: Bool = false
    
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
                self.standardOfferInfoLabel.text = "Discount applies only to the first £20.00 or ₹500.00"
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
        self.actionButton.showLoader()
        
        self.getLocation { (location, error) in
            
            guard error == nil else {
                self.actionButton.hideLoader()
                debugPrint("Error while getting location:  \(String(describing: error?.localizedDescription))")
                return
            }
                     
            if location != nil  {
                self.redeemDeal(location: location ?? CLLocation(latitude: 0.0, longitude: 0.0   ))
            } else {
                debugPrint("location is nil")
            }
        }
       /*
        Analytics.logEvent(bartenderReadyClick, parameters: nil)
        
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, redeemButtonTapped: sender, selectedIndex: self.selectedIndex, redeemType: self.redeemingType)
        }*/
    }
    
    @IBAction func takeMeBackButtonTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate.redeemStartViewController(controller: self, backButtonTapped: sender as! UIButton, selectedIndex: self.selectedIndex)
        }
    }
}

//MARK: My Methods
extension RedeemStartViewController {
    
    func showAlertAndDismiss(msg: String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (alert) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getLocation(completionHandler: @escaping (_ location: CLLocation?, _ error: Error?) -> Void) {
          
        func showSettingsAlert() {
             
            let alertController = UIAlertController(title: "Settings", message: "The venue needs to know your location to verify this offer.", preferredStyle: .alert)
                          
            let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                       
            let settingAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default) {
                      UIAlertAction in
                            
                let url = URL(string: UIApplicationOpenSettingsURLString)!
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                                
                    // Fallback on earlier versions
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
                       
            alertController.addAction(okAction)
            alertController.addAction(settingAction)
            self.present(alertController, animated: true, completion: nil)
        }
          
        debugPrint("Getting location")
          
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.actionButton.showLoader()
          
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = true
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyBest, timeOut: 20.0) {  (location, error) in
                     
            debugPrint("Getting location finished")
              
            UIApplication.shared.endIgnoringInteractionEvents()

            if error != nil  {
                debugPrint("Error while getting location:  \(String(describing: error?.localizedDescription))")
                showSettingsAlert()
                completionHandler(nil, error)
            }
            completionHandler(location, nil)
        }
    }
}

//MARK: WebService Method
extension RedeemStartViewController {
    
    func redeemDeal(location: CLLocation) {
        
        var params: [String: Any] = ["establishment_id" : self.barId!,
                                     "type" : self.redeemingType.rawValue,
                                     "latitude" : location.coordinate.latitude,
                                     "longitude" : location.coordinate.longitude]
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
        
        if self.redeemingType == RedeemType.voucher{
            params["user_voucher_id"] = self.dealInfo.userVoucherId.value
        }
       
        debugPrint("params: \(params)")
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.actionButton.showLoader()

        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            self.actionButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    
                    if self.redeemingType != RedeemType.voucher {
                        try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                                          let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), self.barId!))
                                          for bar in bars {
                                              bar.canRedeemOffer.value = false
                                          }
                                      })
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameDealRedeemed), object: nil, userInfo: nil)
                        }
                                        
                    let msg = "Success! Offer Redeemed"
                    let alertController = UIAlertController(title: "", message: msg, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        
                        self.dismiss(animated: true) {
                            self.delegate.redeemStartViewController(controller: self, redeemStatus: true, selectedIndex: self.selectedIndex)
                        }
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                   
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertAndDismiss(msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertAndDismiss(msg: genericError.localizedDescription)
                self.delegate.redeemStartViewController(controller: self, redeemStatus: false, selectedIndex: self.selectedIndex)

                
            }
        }
    }
}

