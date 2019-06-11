//
//  SIgnUpViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import FBSDKCoreKit
import FBSDKLoginKit
import HTTPStatusCodes
import CoreStore
import CoreLocation
import FirebaseAnalytics

enum Gender: String {
    case male = "male", female = "female", other = "other"
    
    func description() -> String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        default:
            return "Other"
        }
    }
}

class SIgnUpViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var fbSignUpView: UIView!
    
    @IBOutlet var fbSignUpButton: LoadingButton!
    @IBOutlet var signUpButton: GradientButton!
    
    @IBOutlet var termsPolicyTextView: UITextView!
    
    @IBOutlet var contentHeight: NSLayoutConstraint!
    
    var fullNameFieldView: FieldView!
    var emailFieldView: FieldView!
    var passwordFieldView: FieldView!
    var dobFieldView: FieldView!
    var genderFieldView: FieldView!
    
    @IBOutlet var dateInputView: UIView!
    @IBOutlet var pickerInputView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var bottomView: UIView!
    
    let termsScheme = "thebarcode://terms"
    let policyScheme = "thebarcode://policy"
    
    var selectedGender: Gender = Gender.male
    var selectedDob: Date = Date()
    
    var genders: [Gender] = [Gender.male, Gender.female]
    
    var socialAccountId: String?
    var mobileSignUp: Bool = false
    var phoneNo: String = ""
    
    var phoneNoFieldView: FieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbSignUpButton.updateAcivityIndicatorColor(color: UIColor.white)
        
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) //User Age should be min 18
        self.datePicker.maximumDate = nil
        self.datePicker.minimumDate = nil
        self.datePicker.date = date!
        self.selectedDob = self.datePicker.date

        self.addBackButton()
        
        self.setUpFields()
        self.setUpTermsAndPolicyLink()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "SignUpToLoginViaSegue" {
            let controller = segue.destination as! LoginViaViewController
            controller.forSignUp = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = self.bottomView.frame.origin.y + self.bottomView.frame.height + 20.0
        self.contentHeight.constant = height
    }
    
    //MARK: My Methods
    
    func setUpFields() {
        
        self.fullNameFieldView = FieldView.loadFromNib()
        self.fullNameFieldView.setUpFieldView(placeholder: "FULL NAME", fieldPlaceholder: "Enter your full name", iconImage: nil)
        self.fullNameFieldView.setKeyboardType()
        self.fullNameFieldView.setReturnKey(returnKey: .next)
        self.contentView.addSubview(self.fullNameFieldView)
        
        self.fullNameFieldView.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.contentView, withOffset: 24.0)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.fullNameFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter your email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.emailFieldView.setReturnKey(returnKey: .next)
        
        self.phoneNoFieldView = FieldView.loadFromNib()
        self.phoneNoFieldView.textField.text = self.phoneNo
        self.phoneNoFieldView.delegate = self
        self.phoneNoFieldView.setUpFieldView(placeholder: "MOBILE NUMBER", fieldPlaceholder: "Enter mobile number", iconImage: nil)
        self.phoneNoFieldView.textField.isEnabled = false
        self.phoneNoFieldView.setKeyboardType(keyboardType: .phonePad)
        
        self.passwordFieldView = FieldView.loadFromNib()
        self.passwordFieldView.setUpFieldView(placeholder: "PASSWORD", fieldPlaceholder: "Create your account password", iconImage: nil)
        self.passwordFieldView.setKeyboardType()
        self.passwordFieldView.setReturnKey(returnKey: .next)
        self.passwordFieldView.makeSecure(secure: true)
        
        if self.mobileSignUp {
            self.contentView.addSubview(self.phoneNoFieldView)
            
            self.phoneNoFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
            self.phoneNoFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.phoneNoFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.phoneNoFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
        } else {
            self.contentView.addSubview(self.emailFieldView)
            
            self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
            self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
            self.contentView.addSubview(self.passwordFieldView)
            
            self.passwordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
            self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.passwordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
        }
        
        self.dobFieldView = FieldView.loadFromNib()
        self.dobFieldView.delegate = self
        self.dobFieldView.fieldRight.constant = 8.0
        self.dobFieldView.validationLabelRight.constant = 8.0
        self.dobFieldView.setUpFieldView(placeholder: "DATE OF BIRTH", fieldPlaceholder: "DD/MM/YYYY", iconImage: #imageLiteral(resourceName: "icon_calendar"))
        self.dobFieldView.setKeyboardType(inputView: self.dateInputView)
        self.contentView.addSubview(self.dobFieldView)
        
        if self.mobileSignUp {
            self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.phoneNoFieldView, withOffset: 5.0)
        } else {
            self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
        }
        
        self.dobFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.dobFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView = FieldView.loadFromNib()
        self.genderFieldView.delegate = self
        self.genderFieldView.fieldLeft.constant = 8.0
        self.genderFieldView.validationLabelLeft.constant = 8.0
        self.genderFieldView.placeholderLabelLeft.constant = 8.0
        self.genderFieldView.setUpFieldView(placeholder: "GENDER", fieldPlaceholder: "Select gender", iconImage: #imageLiteral(resourceName: "icon_dropdown"))
        self.genderFieldView.setKeyboardType(inputView: self.pickerInputView)
        self.contentView.addSubview(self.genderFieldView)
        
        if self.mobileSignUp {
            self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.phoneNoFieldView, withOffset: 5.0)
        } else {
            self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
        }
        
        self.genderFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.genderFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: self.dobFieldView)
        self.genderFieldView.autoMatch(ALDimension.width, to: ALDimension.width, of: self.dobFieldView)
        
        self.contentView.addSubview(self.bottomView)
        
        self.bottomView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.genderFieldView, withOffset: 0.0)
        self.bottomView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.bottomView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.bottomView.autoSetDimension(ALDimension.height, toSize: 182.0)

        self.view.layoutIfNeeded()
        
        self.fullNameFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.emailFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.passwordFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        
    }
    
    func setUpTermsAndPolicyLink() {
        
        let termsAndPolicy = "By clicking Create Account or Sign Up with Facebook you agree to the Terms of Use and Privacy Policy."
        let termsOfUse = "Terms of Use"
        let privacyPolicy = "Privacy Policy"
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let normalAttributes = [NSAttributedStringKey.foregroundColor : UIColor.appGrayColor(),
                                NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedStringKey.paragraphStyle : paraStyle]
        
        let attributedTermsAndPolicy = NSMutableAttributedString(string: termsAndPolicy, attributes: normalAttributes)
        
        let termsUrl = URL(string: termsScheme)!
        attributedTermsAndPolicy.addAttribute(NSAttributedStringKey.link, value: termsUrl, range: (termsAndPolicy as NSString).range(of: termsOfUse))
        
        let policyUrl = URL(string: policyScheme)!
        attributedTermsAndPolicy.addAttribute(NSAttributedStringKey.link, value: policyUrl, range: (termsAndPolicy as NSString).range(of: privacyPolicy))
        
        let linkAttributes = [NSAttributedStringKey.foregroundColor.rawValue : UIColor.appBlueColor(),
                              NSAttributedStringKey.font.rawValue : UIFont.appRegularFontOf(size: 14.0)] as [String : Any]
        self.termsPolicyTextView.linkTextAttributes = linkAttributes
        
        self.termsPolicyTextView.attributedText = attributedTermsAndPolicy
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if self.fullNameFieldView.textField.text!.trimWhiteSpaces().count < 2 {
            isValid = false
           self.fullNameFieldView.showValidationMessage(message: "Please enter your name.")
        } else {
            self.fullNameFieldView.reset()
        }
        
        if self.mobileSignUp {
            let text = self.phoneNoFieldView.textField.text!
            let mobileNumber = text.unformat("XNN NNNN NNNNNN", oldString: text)
            
            if mobileNumber.count < 13 {
                isValid = false
                self.phoneNoFieldView.showValidationMessage(message: "Please enter valid mobile number")
            } else {
                self.phoneNoFieldView.reset()
            }
            
        } else {
            if !self.emailFieldView.textField.text!.isValidEmail() {
                isValid = false
                self.emailFieldView.showValidationMessage(message: "Please enter valid email address.")
            } else {
                self.emailFieldView.reset()
            }
            
            if self.passwordFieldView.textField.text!.count < 8 {
                isValid = false
                self.passwordFieldView.showValidationMessage(message: "Please enter password of atleast 8 characters.")
            } else {
                self.passwordFieldView.reset()
            }
        }
        
        let age = Calendar.current.dateComponents([.year], from: self.selectedDob, to: Date()).year
        
        if self.dobFieldView.textField.text!.count == 0 {
            isValid = false
            self.dobFieldView.showValidationMessage(message: "Please select your DOB.")
        } else if let age = age, age < 18 {
            isValid = false
            self.dobFieldView.showValidationMessage(message: "You must be 18 years old.")
        } else {
            self.dobFieldView.reset()
        }
        
        if self.genderFieldView.textField.text!.count == 0 {
            isValid = false
            self.genderFieldView.showValidationMessage(message: "Please select your gender.")
        } else {
            self.genderFieldView.reset()
        }
        
        return isValid
    }
    
    @objc func textFieldDidEndOnExit(sender: UITextField) {
        
        if self.mobileSignUp {
            if sender == self.fullNameFieldView.textField {
                self.dobFieldView.textField.becomeFirstResponder()
            }
        } else {
            if sender == self.fullNameFieldView.textField {
                self.emailFieldView.textField.becomeFirstResponder()
            } else if sender == self.emailFieldView.textField {
                self.passwordFieldView.textField.becomeFirstResponder()
            } else if sender == self.passwordFieldView.textField {
                self.dobFieldView.textField.becomeFirstResponder()
            }
        }
        
        
    }
    
    func updateGenderField() {
        self.genderFieldView.textField.text = self.selectedGender.description()
    }
    
    func updateDobField() {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "dd/MM/yyyy"
        self.dobFieldView.textField.text = dateformatter.string(from: self.selectedDob)
    }
    
    func presentTabBarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        self.navigationController?.present(tabbarController!, animated: true, completion: {
            let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
            self.navigationController?.popToViewController(loginOptions, animated: false)
        })
    }
    
    func showVerificationController() {
        if self.mobileSignUp {
            self.showMobileVerificationController()
        } else {
            self.showEmailVerificationController()
        }
    }
    
    func showEmailVerificationController() {
        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as! EmailVerificationViewController)
        verificationController.modalPresentationStyle = .overCurrentContext
        verificationController.delegate = self
        verificationController.isFieldsSecure = false
        verificationController.email = self.emailFieldView.textField.text!
        self.present(verificationController, animated: true, completion: nil)
    }
    
    func showMobileVerificationController() {
        
        let text = self.phoneNoFieldView.textField.text!
        
        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "MobileVerificationViewController") as! MobileVerificationViewController)
        verificationController.modalPresentationStyle = .overCurrentContext
        verificationController.delegate = self
        verificationController.isFieldsSecure = false
        verificationController.mobileNumber = text
        verificationController.isCommingFromSignup = true
        self.present(verificationController, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    
    @IBAction func fbSignUpButtonTapped(sender: UIButton) {
        Analytics.logEvent(signUpFacebookClick, parameters: nil)
        self.socialSignUp()
    }
    
    @IBAction func createAccountButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isDataValid() {
            if mobileSignUp {
                self.signUp()
            } else {
                let alertController = UIAlertController(title: "Info", message: "If you don’t receive your email code, use SMS.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                    self.signUp()
                }))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func doneBarButtonTapped(sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func nextBarButtonTapped(sender: UIBarButtonItem) {
        if self.dobFieldView.textField.isFirstResponder {
            self.genderFieldView.textField.becomeFirstResponder()
        }
    }
    
    @IBAction func previousBarButtonTapped(sender: UIBarButtonItem) {
        if self.mobileSignUp {
            if self.genderFieldView.textField.isFirstResponder {
                self.dobFieldView.textField.becomeFirstResponder()
            } else if self.dobFieldView.textField.isFirstResponder {
                self.fullNameFieldView.textField.becomeFirstResponder()
            }
        } else {
            if self.genderFieldView.textField.isFirstResponder {
                self.dobFieldView.textField.becomeFirstResponder()
            } else if self.dobFieldView.textField.isFirstResponder {
                self.passwordFieldView.textField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        self.selectedDob = sender.date
        self.updateDobField()
    }
    
    @IBAction func signInButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "SignUpToLoginViaSegue", sender: nil)
    }
}

//MARK: UITextViewDelegate

extension SIgnUpViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        if URL.absoluteString == termsScheme {
            self.performSegue(withIdentifier: "SignUpToTermsNavigationSegue", sender: nil)
        } else if URL.absoluteString == policyScheme {
            self.performSegue(withIdentifier: "SignUpToPolicyNavigationSegue", sender: nil)
        }
        
        return false
    }
}

//MARK: FieldViewDelegate
extension SIgnUpViewController: FieldViewDelegate {
    
    func fieldView(fieldView: FieldView, didBeginEditing textField: UITextField) {
        if textField == self.genderFieldView.textField {
            self.updateGenderField()
        } else if textField == self.dobFieldView.textField {
            self.updateDobField()
        }
    }
    
    func fieldView(fieldView: FieldView, didEndEditing textField: UITextField) {
        
    }
}

//MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension SIgnUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 30.0))
        
        var title: String = ""
    
        if genderFieldView.textField.isFirstResponder {
            title = self.genders[row].description()
        }
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .center
        
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 16.0),
                                                         
                                                         NSAttributedStringKey.foregroundColor : UIColor.white,
                                                         NSAttributedStringKey.paragraphStyle : paraStyle]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        titleLabel.attributedText = attributedTitle
        
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedGender = self.genders[row]
        self.updateGenderField()
    }
}

//MARK: EmailVerificationViewControllerDelegate
extension SIgnUpViewController: EmailVerificationViewControllerDelegate {
    func userVerifiedSuccessfully(canShowReferral: Bool) {
        
        guard let user = Utility.shared.getCurrentUser() else {
            self.showAlertController(title: "User Not Found", msg: "User does not exists. Please resign in.")
            return
        }
        
        switch user.status {
        case .active:
            if canShowReferral && user.referralCode.value == nil {
                self.performSegue(withIdentifier: "SignUpToReferralSegue", sender: nil)
            } else if !user.isCategorySelected.value {
                self.performSegue(withIdentifier: "SignUpToCategoriesSegue", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "SignUpToPermissionSegue", sender: nil)
            } else {
                self.presentTabBarController()
            }
            
        case .pending:
            self.showVerificationController()
        default:
            self.showAlertController(title: "Account Blocked", msg: "For some reason your account has been blocked. Please contact admin.")
        }

    }
}

//MARK: MobileVerificationViewControllerDelegate
extension SIgnUpViewController: MobileVerificationViewControllerDelegate {
    func mobileVerificationController(controller: MobileVerificationViewController, userVerifiedSuccessfully canShowReferral: Bool) {
        self.userVerifiedSuccessfully(canShowReferral: canShowReferral)
    }
}

//MARK: Webservices Methods
extension SIgnUpViewController {
    
    func signUp() {
        
        let fullName = self.fullNameFieldView.textField.text!
        let gender = self.selectedGender.rawValue
        let dob = Utility.shared.serverDateFormattedString(date: self.selectedDob)
        
        var params = ["full_name" : fullName,
                      "date_of_birth" : dob]
        
        if self.mobileSignUp {
            
            let text = self.phoneNoFieldView.textField.text!
            let mobileNumber = text.unformat("XNN NNNN NNNNNN", oldString: text)
            
            params["contact_number"] = mobileNumber
        } else {
            
            let email = self.emailFieldView.textField.text!
            let password = self.passwordFieldView.textField.text!
            
            params["email"] = email
            params["password"] = password
        }
        
        params["gender"] =  self.selectedGender != Gender.other  ? gender : ""
        
        if let socialAccountId = self.socialAccountId, let accessToken = FBSDKAccessToken.current()?.tokenString {
            params["social_account_id"] = socialAccountId
            params["access_token"] = accessToken
            
            let profileImage = "https://graph.facebook.com/\(socialAccountId)/picture?width=200&height=200"
            params["profile_image"] = profileImage
        }
        
        self.signUpButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathRegister, method: .post) { (response, serverError, error) in
            
            self.signUpButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseUser = (responseDict?["data"] as? [String : Any]) {
                let user = Utility.shared.saveCurrentUser(userDict: responseUser)
                APIHelper.shared.setUpOAuthHandler(accessToken: user.accessToken.value, refreshToken: user.refreshToken.value)
                self.userVerifiedSuccessfully(canShowReferral: true)
                
            } else {
                let eventName = self.mobileSignUp ? createAccountViaMobile : createAccountViaEmail
                Analytics.logEvent(eventName, parameters: nil)
                self.showVerificationController()
            }
        }
        
    }
    
    func socialSignUp() {
        
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        self.fbSignUpButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        loginManager.logOut()
        loginManager.logIn(withReadPermissions: permissions, from: self) { (result, error) in
            
            guard result?.isCancelled == false else {
                debugPrint("Facebook login cancelled")
                self.fbSignUpButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                return
            }
            
            guard error == nil else {
                self.fbSignUpButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                return
            }
            
            let params = ["fields": "id, name, email, picture.width(180).height(180)"]
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: params)
            graphRequest?.start(completionHandler: { (connection, graphRequestResult, error) in
                
                self.fbSignUpButton.hideLoader()
                UIApplication.shared.endIgnoringInteractionEvents()
                
                guard error == nil else {
                    self.showAlertController(title: "Facebook Login", msg: error!.localizedDescription)
                    return
                }
                
                if let result = graphRequestResult as? [String : Any] {
                    
                    self.fullNameFieldView.textField.text = (result["name"] as! String)
                    self.socialAccountId = "\(result["id"]!)"
                    
                    if let email = result["email"] as? String {
                        self.emailFieldView.textField.text = email
                    }
                    
                    Analytics.logEvent(createAccountViaFacebook, parameters: nil)
                    
                } else {
                    self.showAlertController(title: "", msg: "Unknown error occurred")
                }
            })
            
        }
    }
}
