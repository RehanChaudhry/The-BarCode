//
//  MobileLoginViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/03/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import HTTPStatusCodes
import CoreLocation
import CoreStore
import FirebaseAnalytics

class MobileLoginViewController: UIViewController {

    @IBOutlet var fieldContainerView: UIView!
    @IBOutlet var signInButton: LoadingButton!
    
    var phoneNoFieldView: FieldView!
    
    var locationManager: MyLocationManager!
    
    var forSignUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        if self.forSignUp {
            self.title = "Sign up"
            self.signInButton.setTitle("Sign Up", for: .normal)
        } else {
            self.title = "Welcome back"
            self.signInButton.setTitle("Sign In", for: .normal)
        }
        
        self.phoneNoFieldView = FieldView.loadFromNib()
        self.phoneNoFieldView.textField.text = ""
        self.phoneNoFieldView.delegate = self
        self.phoneNoFieldView.setUpFieldView(placeholder: "MOBILE NUMBER", fieldPlaceholder: "Enter mobile number", iconImage: nil)
        
        self.phoneNoFieldView.setKeyboardType(keyboardType: .phonePad)
        self.fieldContainerView.addSubview(self.phoneNoFieldView)
        
        self.phoneNoFieldView.autoPinEdgesToSuperviewEdges()
        
        self.phoneNoFieldView.textField.becomeFirstResponder()
        
//        self.phoneNoFieldView.prefixLabel.isHidden = true
        self.phoneNoFieldView.prefixLabel.text = Utility.shared.regionalInfo.dialingCode
        self.phoneNoFieldView.prefixLabel.textColor = UIColor.clear
        self.phoneNoFieldView.prefixLabelWidth.constant = 36.0
        self.phoneNoFieldView.prefixLabelMargin.constant = 5.0
        self.phoneNoFieldView.flagView.isHidden = false
        
        self.phoneNoFieldView.flagImageView.image = Utility.shared.regionalInfo.country == INCountryCode ? UIImage(named: "icon_in_flag") : UIImage(named: "icon_flag_uk")
    }
    
    //MARK: My Methods
    func showVerificationController() {
        
        let text = self.phoneNoFieldView.prefixLabel.text! + " " + self.phoneNoFieldView.textField.text!.dropFirst()
        
        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController)
        verificationController.modalPresentationStyle = .overCurrentContext
        verificationController.delegate = self
        verificationController.isFieldsSecure = false
        verificationController.mobileNumber = text
        self.present(verificationController, animated: true, completion: nil)
    }
    
    func presentTabbarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        tabbarController?.modalPresentationStyle = .fullScreen
        self.navigationController?.present(tabbarController!, animated: true, completion: {
            let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
            self.navigationController?.popToViewController(loginOptions, animated: false)
        })
    }
    
    func userVerifiedSuccessfully(canShowReferral: Bool) {
        guard let user = Utility.shared.getCurrentUser() else {
            self.showAlertController(title: "User Not Found", msg: "User does not exists. Please resign in.")
            return
        }
        
        switch user.status {
        case .active:
            if canShowReferral && user.referralCode.value == nil {
                self.performSegue(withIdentifier: "MobileSignInToRefferalSegue", sender: nil)
            } else if !user.isCategorySelected.value {
                self.performSegue(withIdentifier: "MobileSignInToCategoriesSegue", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "MobileSignInToPermissionSegue", sender: nil)
            } else {
                self.getLocation(requestAlwaysAccess: CLLocationManager.authorizationStatus() == .authorizedAlways)
            }
            
        case .pending:
            self.showVerificationController()
        default:
            self.showAlertController(title: "Account Blocked", msg: "For some reason your account has been blocked. Please contact admin.")
        }
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        let text = self.phoneNoFieldView.textField.text!
        let mobileNumber = text.digits //text.unformat("NNNNN NNNNNN", oldString: text)
        
        if mobileNumber.count < 11 {
            isValid = false
            self.phoneNoFieldView.showValidationMessage(message: "Please enter valid mobile number")
        } else {
            self.phoneNoFieldView.reset()
        }
        
        return isValid
    }
    
    //MARK: My IBActions
    @IBAction func signInButtonTapped(sender: UIButton) {
        if self.isDataValid() {
            self.view.endEditing(true)
            self.signIn()
        }
    }

}

//MARK: MobileVerificationViewControllerDelegate
extension MobileLoginViewController: MobileVerificationViewControllerDelegate {
    func mobileVerificationController(controller: MobileVerificationViewController, userVerifiedSuccessfully canShowReferral: Bool) {
        self.userVerifiedSuccessfully(canShowReferral: canShowReferral)
    }
}

//MARK: FieldViewDelegate
extension MobileLoginViewController: FieldViewDelegate {
    func fieldView(fieldView: FieldView, shouldChangeCharactersIn range: NSRange, replacementString string: String, textField: UITextField) -> Bool {
        
        if string == "" {
            textField.text = ""
            return false
        }
        
        if textField.text!.count == 0 && string != "0" {
            textField.text = "0" + string
            return false
        }
        
        guard let text = textField.text else {
            return true
        }
        
       
        
        let lastText = (text as NSString).replacingCharacters(in: range, with: string) as String
        //textField.text = lastText.format("NNNNN NNNNNN", oldString: text)
        
        if lastText.count > 11 {
            return false
        }
        textField.text = lastText
        return false
        
    }
}

//MARK: Webeservices methods
extension MobileLoginViewController {
    func signIn() {
        
        self.signInButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let text = self.phoneNoFieldView.prefixLabel.text! + "" + self.phoneNoFieldView.textField.text!.dropFirst()
        let mobileNumber = text //text.unformat("XNN NNNN NNNNNN", oldString: text)
        let params = ["contact_number" : mobileNumber]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathMobileLogin, method: .post) { (response, serverError, error) in
            
            self.signInButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    let signUpViewController = self.storyboard?.instantiateViewController(withIdentifier: "SIgnUpViewController") as! SIgnUpViewController
                    signUpViewController.signupProvider = .contactNumber
                    signUpViewController.phoneNo = text
                    self.navigationController?.pushViewController(signUpViewController, animated: true)
                } else {
                    self.showAlertController(title: "", msg: serverError!.errorMessages())
                }
                
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let _ = (responseDict?["message"] as? String) {
                self.showVerificationController()
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
    }
    
    func getLocation(requestAlwaysAccess: Bool) {
        
        debugPrint("Getting location")
        
        self.signInButton.showLoader()
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
            self.signInButton.hideLoader()
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
