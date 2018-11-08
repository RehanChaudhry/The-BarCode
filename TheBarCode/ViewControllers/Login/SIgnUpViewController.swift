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
    
    var genders: [Gender] = [Gender.male, Gender.female, Gender.other]
    
    var socialAccountId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fbSignUpButton.updateAcivityIndicatorColor(color: UIColor.white)
        
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.selectedDob = self.datePicker.date
        let date = Calendar.current.date(byAdding: .year, value: -18, to: Date()) //User Age should be min 18
        self.datePicker.maximumDate = date
        self.datePicker.minimumDate = nil

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
        super.prepare(for: segue, sender: nil)
        
    }

    //MARK: My Methods
    
    func setUpFields() {
        
        self.fullNameFieldView = FieldView.loadFromNib()
        self.fullNameFieldView.setUpFieldView(placeholder: "FULL NAME", fieldPlaceholder: "Enter your full name", iconImage: nil)
        self.fullNameFieldView.setKeyboardType()
        self.fullNameFieldView.setReturnKey(returnKey: .next)
        self.contentView.addSubview(self.fullNameFieldView)
        
        self.fullNameFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fbSignUpView, withOffset: 5.0)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.fullNameFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter your email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.emailFieldView.setReturnKey(returnKey: .next)
        self.contentView.addSubview(self.emailFieldView)
        
        self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.passwordFieldView = FieldView.loadFromNib()
        self.passwordFieldView.setUpFieldView(placeholder: "PASSWORD", fieldPlaceholder: "Create your account password", iconImage: nil)
        self.passwordFieldView.setKeyboardType()
        self.passwordFieldView.setReturnKey(returnKey: .next)
        self.passwordFieldView.makeSecure(secure: true)
        self.contentView.addSubview(self.passwordFieldView)
        
        self.passwordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.passwordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.dobFieldView = FieldView.loadFromNib()
        self.dobFieldView.delegate = self
        self.dobFieldView.fieldRight.constant = 8.0
        self.dobFieldView.validationLabelRight.constant = 8.0
        self.dobFieldView.setUpFieldView(placeholder: "DATE OF BIRTH", fieldPlaceholder: "DD/MM/YYYY", iconImage: #imageLiteral(resourceName: "icon_calendar"))
        self.dobFieldView.setKeyboardType(inputView: self.dateInputView)
        self.contentView.addSubview(self.dobFieldView)
        
        self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
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
        
        self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
        self.genderFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.genderFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: self.dobFieldView)
        self.genderFieldView.autoMatch(ALDimension.width, to: ALDimension.width, of: self.dobFieldView)

        let fieldViewsHeight = CGFloat(4.0 * 71.0) + 2.0
        let height = self.fbSignUpView.frame.origin.y + self.fbSignUpView.frame.height + self.bottomView.frame.height + fieldViewsHeight
        self.contentHeight.constant = height

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
        
        if self.dobFieldView.textField.text!.count == 0 {
            isValid = false
            self.dobFieldView.showValidationMessage(message: "Please select your DOB.")
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
        if sender == self.fullNameFieldView.textField {
            self.emailFieldView.textField.becomeFirstResponder()
        } else if sender == self.emailFieldView.textField {
            self.passwordFieldView.textField.becomeFirstResponder()
        } else if sender == self.passwordFieldView.textField {
            self.dobFieldView.textField.becomeFirstResponder()
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
    
    func showVerificationController() {
        let verificationController = (self.storyboard?.instantiateViewController(withIdentifier: "EmailVerificationViewController") as! EmailVerificationViewController)
        verificationController.modalPresentationStyle = .overCurrentContext
        verificationController.delegate = self
        verificationController.isFieldsSecure = false
        verificationController.email = self.emailFieldView.textField.text!
        self.present(verificationController, animated: true, completion: nil)
    }
    
    func presentTabBarController() {
        let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
        self.navigationController?.present(tabbarController!, animated: true, completion: {
            let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
            self.navigationController?.popToViewController(loginOptions, animated: false)
        })
    }
    
    //MARK: My IBActions
    
    @IBAction func fbSignUpButtonTapped(sender: UIButton) {
        self.socialSignUp()
    }
    
    @IBAction func createAccountButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isDataValid() {
            self.signUp()
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
        if self.genderFieldView.textField.isFirstResponder {
            self.dobFieldView.textField.becomeFirstResponder()
        } else if self.dobFieldView.textField.isFirstResponder {
            self.passwordFieldView.textField.becomeFirstResponder()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        self.selectedDob = sender.date
        self.updateDobField()
    }
    
    @IBAction func signInButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "SignUpToSignInSegue", sender: nil)
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

//MARK: Webservices Methods
extension SIgnUpViewController {
    
    func signUp() {
        let fullName = self.fullNameFieldView.textField.text!
        let email = self.emailFieldView.textField.text!
        let password = self.passwordFieldView.textField.text!
        let gender = self.selectedGender.rawValue
        let dob = Utility.shared.serverDateFormattedString(date: self.selectedDob)
        
        var params = ["full_name" : fullName,
                      "email" : email,
                      "password" : password,
                      "date_of_birth" : dob]
        
        if self.selectedGender == Gender.other {
            params["gender"] = nil
        } else  {
            params["gender"] = gender
        }
        
        if let socialAccountId = self.socialAccountId, let accessToken = FBSDKAccessToken.current()?.tokenString {
            params["social_account_id"] = socialAccountId
            params["access_token"] = accessToken
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
                self.showVerificationController()
            }
        }
        
    }
    
    func socialSignUp() {
        
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        self.fbSignUpButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
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
                    
                } else {
                    self.showAlertController(title: "", msg: "Unknown error occurred")
                }
            })
            
        }
    }
}
