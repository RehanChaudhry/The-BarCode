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
import UIColor_Hex_Swift
import Alamofire

class LoginViaViewController: UIViewController {

    @IBOutlet var fbButton: LoadingButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var mobileButton: GradientButton!
    @IBOutlet var instaSignInButton: GradientButton!
    
    var forSignUp: Bool = false
    
    var locationManager: MyLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbButton.updateAcivityIndicatorColor(color: UIColor.white)
        
        self.mobileButton.buttonStandardOfferType = .platinum
        self.mobileButton.updateColor(withGrey: false)
        
        let instagramColors = [UIColor("#405de6"), UIColor("#5851db"), UIColor("#833ab4"), UIColor("#c13584"), UIColor("#e1306c"), UIColor("#fd1d1d")]
        self.instaSignInButton.updateGradient(colors: instagramColors, locations: nil, direction: .right)
        
        if let imageView = self.instaSignInButton.imageView {
            self.instaSignInButton.bringSubview(toFront: imageView)
        }
        
        if let imageView = self.mobileButton.imageView {
            self.mobileButton.bringSubview(toFront: imageView)
        }
        
        self.addBackButton()
        
        if self.forSignUp {
            
            self.title = "Sign up"
            
            self.fbButton.setTitle("Sign up with Facebook", for: .normal)
            self.emailButton.setTitle("Sign up with Email", for: .normal)
            self.mobileButton.setTitle("Sign up with Mobile", for: .normal)
            self.instaSignInButton.setTitle("Sign up with Instagram", for: .normal)
        } else {
            
            self.title = "Sign in"
            
            self.fbButton.setTitle("Sign in with Facebook", for: .normal)
            self.emailButton.setTitle("Sign in with Email", for: .normal)
            self.mobileButton.setTitle("Sign in with Mobile", for: .normal)
            self.instaSignInButton.setTitle("Sign in with Instagram", for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "LoginViaToMobileSignInSegue" {
            let mobileLoginController = segue.destination as! MobileLoginViewController
            mobileLoginController.forSignUp = self.forSignUp
        } else if segue.identifier == "LoginViaToSignUpWithEmailSegue" {
            let signupController = segue.destination as! SIgnUpViewController
            signupController.signupProvider = .email
        }
    }
    
    //MARK: My Methods
    func socialLogin() {
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile"]
        
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
            
            let params = ["fields": "id, name, picture.width(180).height(180)"]
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
                    
                    let socialLoginParams = ["social_account_id" : socialAccountId,
                                             "full_name" : fullName,
                                             "profile_image" : profileImage,
                                             "access_token" : accessToken!,
                                             "provider" : SignUpProvider.facebook.rawValue]
                    
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
                                signUpViewController.facebookParams = (socialAccountId, FBSDKAccessToken.current()!.tokenString)
                                signUpViewController.signupProvider = .facebook
                                let _ = signUpViewController.view
                                self.navigationController?.pushViewController(signUpViewController, animated: true)
                                
                                let name = result["name"] as! String
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
    
    func instaLogin(accessToken: String) {
        
        self.instaSignInButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let params = ["access_token" : accessToken]
        let apiUrl = INSTAGRAM_IDS.INSTAGRAM_APIURl + "self"
        let _ = Alamofire.request(apiUrl, method: .get, parameters: params, encoding: URLEncoding.methodDependent, headers: nil).responseJSON { (result) in
            
            guard result.error == nil else {
                self.instaSignInButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            let response = result.result.value as? [String : Any]
            let responseData = response?["data"] as? [String : Any]
            
            if let instaId = responseData?["id"] as? String,
                let fullName = responseData?["full_name"] as? String {
                
                let profilePic = (responseData?["profile_picture"] as? String) ?? ""
                let socialLoginParams = ["social_account_id" : instaId,
                                         "full_name" : fullName,
                                         "profile_image" : profilePic,
                                         "access_token" : accessToken,
                                         "provider" : SignUpProvider.instagram.rawValue]
                
                let _ = APIHelper.shared.hitApi(params: socialLoginParams, apiPath: apiPathSocialLogin, method: .post, completion: { (response, serverError, error) in
                    
                    guard error == nil else {
                        self.instaSignInButton.hideLoader()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        self.showAlertController(title: "Instagram Login", msg: error!.localizedDescription)
                        return
                    }
                    
                    guard serverError == nil else {
                        
                        self.instaSignInButton.hideLoader()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                            let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SIgnUpViewController") as! SIgnUpViewController
                            signUpViewController.signupProvider = .instagram
                            signUpViewController.instagramParams = (instaId, accessToken, profilePic)
                            let _ = signUpViewController.view
                            self.navigationController?.pushViewController(signUpViewController, animated: true)
                            
                            signUpViewController.fullNameFieldView.textField.text = fullName
                        } else {
                            self.showAlertController(title: "Instagram Login", msg: serverError!.errorMessages())
                        }
                        
                        return
                    }
                    
                    let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
                    if let responseUser = (responseDict?["data"] as? [String : Any]) {
                        
                        let user = Utility.shared.saveCurrentUser(userDict: responseUser)
                        APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
                        
                        self.userVerifiedSuccessfully(canShowReferral: false)
                        
                        if self.forSignUp {
                            Analytics.logEvent(createAccountViaInstagram, parameters:nil)
                        }
                        
                    } else {
                        let genericError = APIHelper.shared.getGenericError()
                        self.showAlertController(title: "", msg: genericError.localizedDescription)
                    }
                    
                    self.fbButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    
                })
                
            } else {
                self.instaSignInButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlertController(title: "", msg: "Unknown response received")
            }
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
            
            if let user = Utility.shared.getCurrentUser() {
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let edittedUser = transaction.edit(user)
                    edittedUser?.latitude.value = location?.coordinate.latitude ?? -1.0
                    edittedUser?.longitude.value = location?.coordinate.longitude ?? -1.0
                    
                })
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
    
    @IBAction func instagramButtonTapped(sender: UIButton) {
        
        let cookieJar : HTTPCookieStorage = HTTPCookieStorage.shared
        for cookie in cookieJar.cookies! as [HTTPCookie] {
            debugPrint("cookie.domain = %@", cookie.domain)
            if cookie.domain.contains("instagram.com") {
                cookieJar.deleteCookie(cookie)
            }
        }
        
        
        let instaNavController = self.storyboard?.instantiateViewController(withIdentifier: "InstagramLoginNavController") as! UINavigationController
        let instaSignInController = (instaNavController.viewControllers.first as! InstagramLoginViewController)
        instaSignInController.delegate = self
        instaSignInController.isSigningUp = self.forSignUp
        self.present(instaNavController, animated: true, completion: nil)
    }
}

//MARK: InstagramLoginViewControllerDelegate
extension LoginViaViewController: InstagramLoginViewControllerDelegate {
    func instagramLoginViewController(controller: InstagramLoginViewController, loggedInSuccessfully accessToke: String) {
        debugPrint("insta accessToke: \(accessToke)")
        self.instaLogin(accessToken: accessToke)
    }
}
