//
//  PermissionsInfoViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import CoreStore

class PermissionsInfoViewController: UIViewController {

    @IBOutlet var overlayView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet var alwaysAllowButton: GradientButton!
    @IBOutlet var whenInUserButton: LoadingButton!
    @IBOutlet var notNowButton: LoadingButton!
    
    @IBOutlet weak var gradientTitleView: GradientView!
    
    var locationManager: MyLocationManager!
    
    var locationPermissionAsked: Bool = false {
        didSet {
            self.presentTabbarController()
        }
    }
    
    var notificationPermissionAsked: Bool = false {
        didSet {
            self.presentTabbarController()
        }
    }
    
    var permissionsDenied: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.hidesBackButton = true
        self.overlayView.isHidden = true
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
        
        self.headerView.roundCorners(corners: UIRectCorner.topLeft, radius: 8.0)
        self.headerView.roundCorners(corners: UIRectCorner.topRight, radius: 8.0)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showOverlayView() {
        self.overlayView.alpha = 0.0
        self.overlayView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 1.0
        }) { (completed: Bool) in
            
        }
    }
    
    func hideOverlayView(completion: @escaping (() -> Void)) {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 0.0
        }) { (completed: Bool) in
            self.overlayView.isHidden = true
            completion()
        }
    }
    
    func presentTabbarController() {
        if self.canPresentTabBar() {
            self.forcefullyPresentTabbarController()
        }
    }
    
    func forcefullyPresentTabbarController() {
        DispatchQueue.main.async {
            let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
            self.navigationController?.present(tabbarController!, animated: true, completion: {
                let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                self.navigationController?.popToViewController(loginOptions, animated: false)
            })
        }
    }
    
    func askForPushNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .notDetermined) {
                center.requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
                    self.notificationPermissionAsked = true
                })
            } else {
                self.notificationPermissionAsked = true
            }
        }
    }
    
    func hideLoaders() {
        self.alwaysAllowButton.hideLoader()
        self.whenInUserButton.hideLoader()
        self.notNowButton.hideLoader()
    }
    
    func canPresentTabBar() -> Bool {
        if self.permissionsDenied {
            return true
        } else {
            return (self.locationPermissionAsked && self.notificationPermissionAsked)
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func askMeButtonTapped(sender: UIButton) {
        self.showOverlayView()
    }
    
    @IBAction func notNowButtonTapped(sender: UIButton) {
        
        self.hideLoaders()
        self.notNowButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.permissionsDenied = true
        self.updateLocation(location: nil)
    }
    
    @IBAction func alwaysAllowButtonTapped(sender: UIButton) {
        
        self.hideLoaders()
        self.alwaysAllowButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.permissionsDenied = false
        self.askForPushNotificationPermissions()
        self.getLocation(requestAlwaysAccess: true)
    }
    
    @IBAction func whileUsingAppButtonTapped(sender: UIButton) {
        
        self.hideLoaders()
        self.whenInUserButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.permissionsDenied = false
        self.askForPushNotificationPermissions()
        self.getLocation(requestAlwaysAccess: false)
        
    }
}

//MARK: Webservices Method
extension PermissionsInfoViewController {
    func getLocation(requestAlwaysAccess: Bool) {
        
        debugPrint("Getting location")
        
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyHundredMeters, timeOut: 20.0) { [unowned self] (location, error) in
            
            debugPrint("Getting location finished")
            
            if let error = error {
                debugPrint("Error while getting location: \(error.localizedDescription)")
            }
            
            self.updateLocation(location: location)
            
        }
    }
    
    func updateLocation(location: CLLocation?) {
        
        debugPrint("Updating location")
        
        let user = Utility.shared.getCurrentUser()!
        
        //Unable to get location and it never called location update before
        if location == nil && user.isLocationUpdated.value {
            debugPrint("Preventing -1, -1 location update")
            self.hideLoaders()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.hideOverlayView {
                self.forcefullyPresentTabbarController()
            }
            
        } else {
            var params: [String : Any] = ["latitude" : "\(location?.coordinate.latitude ?? -1.0)",
                "longitude" : "\(location?.coordinate.longitude ?? -1.0)"]
            if !Utility.shared.getCurrentUser()!.isLocationUpdated.value {
                params["send_five_day_notification"] = true
            }
            
            let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
                
                debugPrint("Updating location finished")
                
                self.hideLoaders()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                guard error == nil else {
                    debugPrint("Error while updating location: \(error!.localizedDescription)")
                    self.showAlertController(title: "", msg: error!.localizedDescription)
                    return
                }
                
                guard serverError == nil else {
                    debugPrint("Server error while updating location: \(serverError!.errorMessages())")
                    self.showAlertController(title: "", msg: serverError!.errorMessages())
                    return
                }
                
                debugPrint("Location update successfully")
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let edittedUser = transaction.edit(user)
                    edittedUser?.isLocationUpdated.value = true
                })
                
                self.hideOverlayView {
                    if self.permissionsDenied {
                        self.presentTabbarController()
                    } else {
                        self.locationPermissionAsked = true
                    }
                }
                
            })
        }
    }
    
}
