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

class LoginViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var fbSignInView: UIView!
    
    @IBOutlet var fbSignInButton: UIButton!
    
    var emailFieldView: FieldView!
    var passwordFieldView: FieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        self.setUpFields()
        
        self.emailFieldView.textField.text = "mzeeshan+5@cygnismedia.com"
        self.passwordFieldView.textField.text = "12345678"
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
        verificationController.email = self.emailFieldView.textField.text!
        self.present(verificationController, animated: true, completion: nil)
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
    func userVerifiedSuccessfully() {
        
        guard let user = Utility.shared.getCurrentUser() else {
            self.showAlertController(title: "User Not Found", msg: "User does not exists. Please resign in.")
            return
        }

        switch user.status {
        case .active:
            if !user.isCategorySelected.value {
                self.performSegue(withIdentifier: "SignInToCategoriesSegue", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "SignInToPermissionSegue", sender: nil)
            } else {
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
                self.navigationController?.present(tabbarController!, animated: true, completion: {
                    let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                    self.navigationController?.popToViewController(loginOptions, animated: false)
                })
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
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAuthenticate, method: .post) { (response, serverError, error) in
            
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
                let _ = Utility.shared.saveCurrentUser(userDict: responseUser)
                self.userVerifiedSuccessfully()
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
    
    func socialLogin() {
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        loginManager.logIn(withReadPermissions: permissions, from: self) { (result, error) in
            
            guard result?.isCancelled == false else {
                debugPrint("Facebook login cancelled")
                return
            }
            
            guard error == nil else {
                self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                return
            }
            
            let params = ["fields": "id, name, email, picture.width(180).height(180)"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            graphRequest?.start(completionHandler: { (connection, graphRequestResult, error) in
                
                guard error == nil else {
                    self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                    return
                }
                
                if let result = graphRequestResult as? [String : Any] {
                    
                    let socialAccountId = "\(result["id"]!)"
                    let fullName = result["name"] as! String
                    let profileImage = "http://graph.facebook.com/\(socialAccountId)/picture?width=200&height=200"
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
                            self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                            return
                        }
                        
                        guard serverError == nil else {
                            
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
                            
                            let _ = Utility.shared.saveCurrentUser(userDict: responseUser)
                            
                            self.userVerifiedSuccessfully()
                            
                        } else {
                            let genericError = APIHelper.shared.getGenericError()
                            self.showAlertController(title: "", msg: genericError.localizedDescription)
                        }
                        
                    })
                    
                } else {
                    self.showAlertController(title: "", msg: "Unknown error occurred")
                }
            })
            
        }
    }
    
}
