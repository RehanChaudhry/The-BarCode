//
//  LoginViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import CoreLocation
import HTTPStatusCodes
import FBSDKLoginKit
import FBSDKCoreKit
import CoreStore

class LoginViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var fbSignInView: UIView!
    
    @IBOutlet var fbSignInButton: LoadingButton!
    
    @IBOutlet var signInButton: GradientButton!
    
    var emailFieldView: FieldView!
    var passwordFieldView: FieldView!
    
    var locationManager: MyLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbSignInButton.updateAcivityIndicatorColor(color: UIColor.white)
        self.addBackButton()
        self.setUpFields()
        
        /*
        self.emailFieldView.textField.text = "mzeeshan+5@cygnismedia.com"
        self.passwordFieldView.textField.text = "12345678"
         */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func setUpFields() {
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter your email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.emailFieldView.setReturnKey(returnKey: .next)
        self.fbSignInView.addSubview(self.emailFieldView)
        
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.top)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.passwordFieldView = FieldView.loadFromNib()
        self.passwordFieldView.setUpFieldView(placeholder: "PASSWORD", fieldPlaceholder: "Enter your account password", iconImage: nil)
        self.passwordFieldView.setKeyboardType()
        self.passwordFieldView.setReturnKey(returnKey: .done)
        self.passwordFieldView.makeSecure(secure: true)
        self.fbSignInView.addSubview(self.passwordFieldView)
        
        self.passwordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.passwordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.passwordFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
    }
    
    @objc func textFieldDidEndOnExit(sender: UITextField) {
        if sender == self.emailFieldView.textField {
            self.passwordFieldView.textField.becomeFirstResponder()
        }
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if !self.emailFieldView.textField.text!.isValidEmail() {
            isValid = false
            self.emailFieldView.showValidationMessage(message: "Please enter valid email address.")
        } else {
            self.emailFieldView.reset()
        }
        
        if self.passwordFieldView.textField.text!.count < 6 {
            isValid = false
            self.passwordFieldView.showValidationMessage(message: "Please enter valid password.")
        } else {
            self.passwordFieldView.reset()
        }
        
        return isValid
    }
    
    func showVerificationController() {
        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as! EmailVerificationViewController)
        verificationController.modalPresentationStyle = .overCurrentContext
        verificationController.delegate = self
        verificationController.isFieldsSecure = false
        verificationController.email = self.emailFieldView.textField.text!
        self.present(verificationController, animated: true, completion: nil)
    }
    
    func presentTabbarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        self.navigationController?.present(tabbarController!, animated: true, completion: {
            let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
            self.navigationController?.popToViewController(loginOptions, animated: false)
        })
    }
    
    //MARK: My IBActions
    
    @IBAction func fbSignInButtonTapped(sender: UIButton) {
        self.socialLogin()
    }
    
    @IBAction func signInButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isDataValid() {
            self.login()
        }
    }
}

//MARK: EmailVerificationViewControllerDelegate
extension LoginViewController: EmailVerificationViewControllerDelegate {
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
}

//MARK: Webservices Method
extension LoginViewController {
    
    func login() {
        
        let email = self.emailFieldView.textField.text!
        let password = self.passwordFieldView.textField.text!
        
        let params: [String : Any] = ["email" : email,
                                      "password" : password]
        
        self.signInButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAuthenticate, method: .post) { (response, serverError, error) in
            
            defer {
                self.signInButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
            
            guard error == nil else {
                self.showAlertController(title: "Authentication", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.gone.rawValue {
                    self.showVerificationController()
                } else {
                    self.showAlertController(title: "Authentication", msg: serverError!.errorMessages())
                }
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseUser = (responseDict?["data"] as? [String : Any]) {
                let user = Utility.shared.saveCurrentUser(userDict: responseUser)
                APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
                
                self.userVerifiedSuccessfully(canShowReferral: false)
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
    
    func socialLogin() {
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        self.fbSignInButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        loginManager.logIn(withReadPermissions: permissions, from: self) { (result, error) in
            
            guard result?.isCancelled == false else {
                debugPrint("Facebook login cancelled")
                self.fbSignInButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            guard error == nil else {
                self.fbSignInButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                return
            }
            
            let params = ["fields": "id, name, email, picture.width(180).height(180)"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            graphRequest?.start(completionHandler: { (connection, graphRequestResult, error) in
                
                guard error == nil else {
                    self.fbSignInButton.hideLoader()
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
                            self.fbSignInButton.hideLoader()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                            return
                        }
                        
                        guard serverError == nil else {
                            
                            self.fbSignInButton.hideLoader()
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
                            
                            
                        } else {
                            let genericError = APIHelper.shared.getGenericError()
                            self.showAlertController(title: "", msg: genericError.localizedDescription)
                        }
                        
                        self.fbSignInButton.hideLoader()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                    })
                    
                } else {
                    self.fbSignInButton.hideLoader()
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.showAlertController(title: "", msg: "Unknown error occurred")
                }
            })
            
        }
    }
    
    func getLocation(requestAlwaysAccess: Bool) {
        
        debugPrint("Getting location")
        
        self.signInButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
            self.signInButton.hideLoader()
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
                
                self.signInButton.hideLoader()
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
    
}
