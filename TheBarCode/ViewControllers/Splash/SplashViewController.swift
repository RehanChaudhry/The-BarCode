//
//  ViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import CoreLocation
import UserNotifications

class SplashViewController: UIViewController {

    var locationManager: MyLocationManager!
    
    var isViewAlreadyLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.checkForUpdate()
        
        if let influencerId = UserDefaults.standard.string(forKey: "influencerId") {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.syncInfluencerInstallation(influencerId: influencerId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.isViewAlreadyLoaded {
            self.isViewAlreadyLoaded = true
            
//            self.showForceUpdateAlert()
        }
        
    }

    //MARK: My Methods
    @objc func moveToNextController() {
        self.performSegue(withIdentifier: "SplashToLoginOptions", sender: nil)
    }
    
    func showForceUpdateAlert() {
        let cannotRedeemViewController = self.storyboard?.instantiateViewController(withIdentifier: "CannotRedeemViewController") as! CannotRedeemViewController
        cannotRedeemViewController.messageText = "A new version is available for The BarCode. Please update your app."
        cannotRedeemViewController.titleText = "We Have Made Changes!"
        cannotRedeemViewController.headerImageName = "login_intro_reload_5"
        cannotRedeemViewController.modalPresentationStyle = .overCurrentContext
        cannotRedeemViewController.delegate = self
        self.present(cannotRedeemViewController, animated: true, completion: nil)
        
        cannotRedeemViewController.cancelButton.isHidden = true
        cannotRedeemViewController.actionButton.setTitle("Update", for: .normal)
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        return version
    }
}

//MARK: CannotRedeemViewControllerDelegate
extension SplashViewController: CannotRedeemViewControllerDelegate {
    
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton) {
        let url = URL(string: appstoreUrlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: { (finish) in
            self.showForceUpdateAlert()
        })
    }
    
    func cannotRedeemController(controller: CannotRedeemViewController, crossButtonTapped sender: UIButton) {
        let url = URL(string: appstoreUrlString)
        UIApplication.shared.open(url!, options: [:], completionHandler: { (finish) in
            self.showForceUpdateAlert()
        })
    }
}

//Webservices Methods
extension SplashViewController {
    
    func checkForUpdate() {

        let version = self.version()
        let params = ["version" : version,
                      "platform" : platform]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathVersionCheck, method: .get, completion: { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting version: \(error!.localizedDescription)")
                self.updateLocationIfNeed()
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while getting version: \(serverError!.errorMessages())")
                self.updateLocationIfNeed()
                return
            }
            
            let responseDict = (response as? [String : Any])?["response"] as? [String : Any]
            if let responseData = (responseDict?["data"] as? [String : Any]), let forceUpdate = responseData["force_update"] as? Bool {
                
                if forceUpdate {
                    self.showForceUpdateAlert()
                } else {
                    self.updateLocationIfNeed()
                }
                
            } else {
                self.updateLocationIfNeed()
            }
        })
    }
    
    func updateLocationIfNeed() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User does not exists for location update")
            self.moveToNextController()
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        var canContinue: Bool? = nil
        if authorizationStatus == .authorizedAlways {
            canContinue = true
        } else if authorizationStatus == .authorizedWhenInUse {
            canContinue = false
        }
        
        guard let requestAlwaysAccess = canContinue else {
            debugPrint("Location permission not authorized")
            self.moveToNextController()
            return
        }
        
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyBestForNavigation, timeOut: 20.0) { [unowned self] (location, error) in
            
            guard error == nil else {
                debugPrint("Error while getting location: \(error!.localizedDescription)")
                self.moveToNextController()
                return
            }
            
            var params = ["latitude" : "\(location!.coordinate.latitude)",
                "longitude" : "\(location!.coordinate.longitude )"] as [String : Any]
            
            try! CoreStore.perform(synchronous: { (transaction) -> Void in
                let edittedUser = transaction.edit(user)
                edittedUser?.latitude.value = location!.coordinate.latitude
                edittedUser?.longitude.value = location!.coordinate.longitude

            })
            
            if !Utility.shared.getCurrentUser()!.isLocationUpdated.value {
                params["send_five_day_notification"] = true
            }
            
            let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
                
                defer {
                    self.moveToNextController()
                }
                
                guard error == nil else {
                    debugPrint("Error while updating location: \(error!.localizedDescription)")
                    return
                }
                
                guard serverError == nil else {
                    debugPrint("Server error while updating location: \(serverError!.errorMessages())")
                    return
                }
                
                debugPrint("Location update successfully")

                let responseDict = response as? [String : Any]
                if let responseData = (responseDict?["data"] as? [String : Any])
                {
                    if let creditValue = responseData["credit"] as? Int {
                        debugPrint("credit == \(creditValue)")
                        Utility.shared.userCreditUpdate(creditValue: creditValue)
                    }

                }
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let edittedUser = transaction.edit(user)
                    edittedUser?.isLocationUpdated.value = true
                })
                
                
            })
        }
    }
}

