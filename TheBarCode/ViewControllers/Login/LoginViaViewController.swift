//
//  LoginViaViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/03/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import CoreLocation
import HTTPStatusCodes
import FBSDKLoginKit
import FBSDKCoreKit
import CoreStore
import FirebaseAnalytics

class LoginViaViewController: UIViewController {

    @IBOutlet var fbButton: LoadingButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var mobileButton: GradientButton!
    
    var forSignUp: Bool = false
    
    var locationManager: MyLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbButton.updateAcivityIndicatorColor(color: UIColor.white)
        
        self.mobileButton.buttonStandardOfferType = .platinum
        self.mobileButton.updateColor(withGrey: false)
        
        self.addBackButton()
        
        if self.forSignUp {
            
            self.title = "Sign up"
            
            self.fbButton.setTitle("Sign up with Facebook", for: .normal)
            self.emailButton.setTitle("Sign up with Email", for: .normal)
            self.mobileButton.setTitle("Sign up with Mobile", for: .normal)
        } else {
            
            self.title = "Sign in"
            
            self.fbButton.setTitle("Sign in with Facebook", for: .normal)
            self.emailButton.setTitle("Sign in with Email", for: .normal)
            self.mobileButton.setTitle("Sign in with Mobile", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "LoginViaToMobileSignInSegue" {
            let mobileLoginController = segue.destination as! MobileLoginViewController
            mobileLoginController.forSignUp = self.forSignUp
        }
    }
    
    //MARK: My Methods
    func socialLogin() {
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        self.fbButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: permissions, from: self) { (result, error) in
            
            guard result?.isCancelled == false else {
                debugPrint("Facebook login cancelled")
                self.fbButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            guard error == nil else {
                self.fbButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                return
            }
            
            let params = ["fields": "id, name, email, picture.width(180).height(180)"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            graphRequest?.start(completionHandler: { (connection, graphRequestResult, error) in
                
                guard error == nil else {
                    self.fbButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                    return
                }
                
                if let result = graphRequestResult as? [String : Any] {
                    
                    let socialAccountId = "\(result["id"]!)"
                    let fullName = result["name"] as! String
                    let profileImage = "https://graph.facebook.com/\(socialAccountId)/picture?width=200&height=200"
                    let accessToken = FBSDKAccessToken.current()!.tokenString
                    let email = result["email"] as? String
                    
                    var socialLoginParams = ["social_account_id" : socialAccountId,
                                             "full_name" : fullName,
                                             "profile_image" : profileImage,
                                             "access_token" : accessToken!]
                    if let email = email {
                        socialLoginParams["email"] = email
                    }
                    
                    let _ = APIHelper.shared.hitApi(params: socialLoginParams, apiPath: apiPathSocialLogin, method: .post, completion: { (response, serverError, error) in
                        
                        guard error == nil else {
                            self.fbButton.hideLoader()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                            return
                        }
                        
                        guard serverError == nil else {
                            
                            self.fbButton.hideLoader()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                                
                                let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SIgnUpViewController") as! SIgnUpViewController
                                signUpViewController.socialAccountId = socialAccountId
                                let _ = signUpViewController.view
                                self.navigationController?.pushViewController(signUpViewController, animated: true)
                                
                                let name = result["name"] as! String
                                if let email = result["email"] as? String {
                                    signUpViewController.emailFieldView.textField.text = email
                                }
                                
                                signUpViewController.fullNameFieldView.textField.text = name
                            } else {
                                self.showAlertController(title: "Facebook Login", msg: serverError!.errorMessages())
                            }
                            
                            return
                        }
                        
                        let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
                        if let responseUser = (responseDict?["data"] as? [String : Any]) {
                            
                            let user = Utility.shared.saveCurrentUser(userDict: responseUser)
                            APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
                            
                            self.userVerifiedSuccessfully(canShowReferral: false)
                            
                            if self.forSignUp {
                                Analytics.logEvent(createAccountViaFacebook, parameters:nil)
                            }
                            
                        } else {
                            let genericError = APIHelper.shared.getGenericError()
                            self.showAlertController(title: "", msg: genericError.localizedDescription)
                        }
                        
                        self.fbButton.hideLoader()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    })
                    
                } else {
                    self.fbButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlertController(title: "", msg: "Unknown error occurred")
                }
            })
            
        }
    }
    
    func userVerifiedSuccessfully(canShowReferral: Bool) {
        
        guard let user = Utility.shared.getCurrentUser() else {
            self.showAlertController(title: "User Not Found", msg: "User does not exists. Please resign in.")
            return
        }
        
        switch user.status {
        case .active:
            if canShowReferral && user.referralCode.value == nil {
                self.performSegue(withIdentifier: "SignInToReferralSegue", sender: nil)
            } else if !user.isCategorySelected.value {
                self.performSegue(withIdentifier: "SignInToCategoriesSegue", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "SignInToPermissionSegue", sender: nil)
            } else {
                self.getLocation(requestAlwaysAccess: CLLocationManager.authorizationStatus() == .authorizedAlways)
            }
            
        case .pending:
            self.showVerificationController()
        default:
            self.showAlertController(title: "Account Blocked", msg: "For some reason your account has been blocked. Please contact admin.")
        }
        
    }
    
    func getLocation(requestAlwaysAccess: Bool) {
        
        debugPrint("Getting location")
        
        self.fbButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        self.locationManager = MyLocationManager()
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyBestForNavigation, timeOut: 20.0) { [unowned self] (location, error) in
            
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
            self.fbButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            self.presentTabbarController()
            
        } else {
            var params: [String : Any] = ["latitude" : "\(location?.coordinate.latitude ?? -1.0)",
                "longitude" : "\(location?.coordinate.longitude ?? -1.0)"]
            if !user.isLocationUpdated.value {
                params["send_five_day_notification"] = true
            }
            
            let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathLocationUpdate, method: .put, completion: { (response, serverError, error) in
                
                debugPrint("Updating location finished")
                
                self.fbButton.hideLoader()
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
                
                self.presentTabbarController()
                
            })
        }
    }
    
    func presentTabbarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        self.navigationController?.present(tabbarController!, animated: true, completion: {
            let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
            self.navigationController?.popToViewController(loginOptions, animated: false)
        })
    }
    
    func showVerificationController() {
//        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as! EmailVerificationViewController)
//        verificationController.modalPresentationStyle = .overCurrentContext
//        verificationController.delegate = self
//        verificationController.isFieldsSecure = false
//        verificationController.email = self.emailFieldView.textField.text!
//        self.present(verificationController, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    @IBAction func fbButtonTapped(sender: UIButton) {
        let eventName = self.forSignUp ? signUpFacebookClick : signInFacebookClick
        Analytics.logEvent(eventName, parameters: nil)
        self.socialLogin()
    }

    @IBAction func emailButtonTapped(sender: UIButton) {
        let eventName = self.forSignUp ? signUpEmailClick : signInEmailClick
        Analytics.logEvent(eventName, parameters: nil)
        
        if self.forSignUp {
            self.performSegue(withIdentifier: "LoginViaToSignUpWithEmailSegue", sender: nil)
        } else {
            self.performSegue(withIdentifier: "LoginViaToSignInWithEmailSegue", sender: nil)
        }
    }
    
    @IBAction func mobileButtonTapped(sender: UIButton) {
        let eventName = self.forSignUp ? signUpMobileClick : signInMobileClick
        Analytics.logEvent(eventName, parameters: nil)
        
        self.performSegue(withIdentifier: "LoginViaToMobileSignInSegue", sender: nil)
    }
}
