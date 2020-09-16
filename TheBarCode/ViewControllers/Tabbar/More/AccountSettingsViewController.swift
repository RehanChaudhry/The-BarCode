//
//  AccountSettingsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import FBSDKCoreKit
import FBSDKLoginKit
import CoreStore
import FirebaseAnalytics

class AccountSettingsViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var profileInfoView: UIView!
    @IBOutlet var profileImageView: AsyncImageView!
    
    @IBOutlet var contentHeight: NSLayoutConstraint!

    @IBOutlet var dateInputView: UIView!
    @IBOutlet var pickerInputView: UIView!
    
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var pickerView: UIPickerView!
    
    @IBOutlet var passwordSectionHeaderView: UIView!
    
    @IBOutlet var updateButton: GradientButton!
    
    @IBOutlet var loginInfoLabel: UILabel!
    @IBOutlet var socialLogoutButton: UIButton!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var fullNameFieldView: FieldView!
    var emailFieldView: FieldView!
    var dobFieldView: FieldView!
    var genderFieldView: FieldView!
    var postcodeFieldView: FieldView!

    var currentPasswordFieldView: FieldView!
    var passwordFieldView: FieldView!
    var confirmPasswordFieldView: FieldView!
    
    var selectedGender: Gender = Gender.male
    var selectedDob: Date = Date()
    
    var genders: [Gender] = Gender.allGenders()
    
    var phoneNoFieldView: FieldView!
    
    var signupProvider: SignUpProvider!
//    var isLoggedInViaMobile: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        self.socialLogoutButton.isHidden = true
        
        self.profileImageView.layer.borderColor = UIColor.appGradientGrayStart().cgColor
        self.profileImageView.layer.borderWidth = 1.0
        
        self.datePicker.maximumDate = nil
        self.datePicker.minimumDate = nil
        self.datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        self.selectedDob = self.datePicker.date
        
        self.addBackButton()
        
        self.signupProvider = Utility.shared.getCurrentUser()?.provider ?? .email
        
        self.setUpFields()
        self.setUpUserProfile()
        
        Analytics.logEvent(viewAccountSettingScreen, parameters: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.contentHeight.constant = self.updateButton.frame.origin.y + self.updateButton.frame.height + 24.0
    }
    
    //MARK: My Methods
    
    func setUpFields() {
        
        self.fullNameFieldView = FieldView.loadFromNib()
        self.fullNameFieldView.setUpFieldView(placeholder: "FULL NAME", fieldPlaceholder: "Enter your full name", iconImage: nil)
        self.fullNameFieldView.setKeyboardType()
        self.fullNameFieldView.setReturnKey(returnKey: .next)
        self.contentView.addSubview(self.fullNameFieldView)
        
        self.fullNameFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.profileInfoView, withOffset: 24.0)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.fullNameFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter your email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.emailFieldView.setReturnKey(returnKey: .next)
        self.emailFieldView.isUserInteractionEnabled = false
        
        var mobileNumber = Utility.shared.getCurrentUser()?.mobileNumber.value ?? ""
        mobileNumber = mobileNumber.format("XNN NNNN NNNNNN", oldString: mobileNumber)
        
        self.phoneNoFieldView = FieldView.loadFromNib()
        self.phoneNoFieldView.textField.text = mobileNumber
        self.phoneNoFieldView.delegate = self
        self.phoneNoFieldView.setUpFieldView(placeholder: "MOBILE NUMBER", fieldPlaceholder: "Enter mobile number", iconImage: nil)
        self.phoneNoFieldView.textField.isEnabled = false
        self.phoneNoFieldView.setKeyboardType(keyboardType: .phonePad)
        
        if self.signupProvider == .contactNumber {
            self.contentView.addSubview(self.phoneNoFieldView)
            
            self.phoneNoFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
            self.phoneNoFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.phoneNoFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.phoneNoFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        } else if self.signupProvider == .email {
            self.contentView.addSubview(self.emailFieldView)
            
            self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
            self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        } else {
            
        }

        self.dobFieldView = FieldView.loadFromNib()
        self.dobFieldView.delegate = self
        self.dobFieldView.fieldRight.constant = 8.0
        self.dobFieldView.validationLabelRight.constant = 8.0
        self.dobFieldView.setUpFieldView(placeholder: "DATE OF BIRTH", fieldPlaceholder: "DD/MM/YYYY", iconImage: #imageLiteral(resourceName: "icon_calendar"))
        self.dobFieldView.setKeyboardType(inputView: self.dateInputView)
        self.contentView.addSubview(self.dobFieldView)
        
        if self.signupProvider == .contactNumber {
            self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.phoneNoFieldView, withOffset: 5.0)
        } else if self.signupProvider == .email {
            self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
        } else {
            self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
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
        
        self.postcodeFieldView = FieldView.loadFromNib()
        self.postcodeFieldView.setUpFieldView(placeholder: "POSTCODE", fieldPlaceholder: "Enter your postcode", iconImage: nil)
        self.postcodeFieldView.setKeyboardType()
        self.postcodeFieldView.setReturnKey(returnKey: .next)
        self.postcodeFieldView.delegate = self

        self.contentView.addSubview(self.postcodeFieldView)
        
        if self.signupProvider == .contactNumber {
            self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.phoneNoFieldView, withOffset: 5.0)
        } else if self.signupProvider == .email {
            self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
        } else {
            self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
        }
        
        self.genderFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.genderFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: self.dobFieldView)
        self.genderFieldView.autoMatch(ALDimension.width, to: ALDimension.width, of: self.dobFieldView)
        
        self.postcodeFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.genderFieldView, withOffset: 5.0)
        self.postcodeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.postcodeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.postcodeFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.currentPasswordFieldView = FieldView.loadFromNib()
        self.currentPasswordFieldView.setUpFieldView(placeholder: "CURRENT PASSWORD", fieldPlaceholder: "Enter your current password", iconImage: nil)
        self.currentPasswordFieldView.setKeyboardType()
        self.currentPasswordFieldView.setReturnKey(returnKey: .next)
        self.currentPasswordFieldView.makeSecure(secure: true)
        
        
        self.passwordFieldView = FieldView.loadFromNib()
        self.passwordFieldView.setUpFieldView(placeholder: "NEW PASSWORD", fieldPlaceholder: "Enter your new password", iconImage: nil)
        self.passwordFieldView.setKeyboardType()
        self.passwordFieldView.setReturnKey(returnKey: .next)
        self.passwordFieldView.makeSecure(secure: true)
        
        
        self.confirmPasswordFieldView = FieldView.loadFromNib()
        self.confirmPasswordFieldView.setUpFieldView(placeholder: "CONFIRM PASSWORD", fieldPlaceholder: "Re-enter your new password", iconImage: nil)
        self.confirmPasswordFieldView.setKeyboardType()
        self.confirmPasswordFieldView.setReturnKey(returnKey: .done)
        self.confirmPasswordFieldView.makeSecure(secure: true)
        
        if self.signupProvider == .email {
            self.contentView.addSubview(self.passwordSectionHeaderView)
            
            self.passwordSectionHeaderView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.postcodeFieldView, withOffset: 0.0)
            self.passwordSectionHeaderView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.passwordSectionHeaderView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.passwordSectionHeaderView.autoSetDimension(ALDimension.height, toSize: 46.0)
            
            self.contentView.addSubview(self.currentPasswordFieldView)
            
            self.currentPasswordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordSectionHeaderView, withOffset: 10.0)
            self.currentPasswordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.currentPasswordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.currentPasswordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
            self.contentView.addSubview(self.passwordFieldView)
            
            self.passwordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.currentPasswordFieldView, withOffset: 10.0)
            self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.passwordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
            self.contentView.addSubview(self.confirmPasswordFieldView)
            
            self.confirmPasswordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
            self.confirmPasswordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
            self.confirmPasswordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
            self.confirmPasswordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
            
            self.contentView.addSubview(self.updateButton)
            self.updateButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.confirmPasswordFieldView, withOffset: 16.0)
        } else {
            self.contentView.addSubview(self.updateButton)
            self.updateButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.postcodeFieldView, withOffset: 16.0)
        }

        self.updateButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: 16.0)
        self.updateButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: 16.0)
        self.updateButton.autoSetDimension(ALDimension.height, toSize: 44.0)
        
        self.updateButton.setNeedsDisplay()
        self.view.layoutIfNeeded()
        
        self.fullNameFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.emailFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.passwordFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.confirmPasswordFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        self.currentPasswordFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
        
    }
    
    func setUpUserProfile(showSuccessAlert: Bool = false) {
        
        guard let user = Utility.shared.getCurrentUser() else {
            debugPrint("User not found")
            return
        }
        
        self.currentPasswordFieldView.textField.text = ""
        self.confirmPasswordFieldView.textField.text = ""
        self.passwordFieldView.textField.text = ""
        
        self.emailFieldView.textField.text = user.email.value
        self.fullNameFieldView.textField.text = user.fullName.value
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = serverDateFormat
        self.selectedDob = dateFormatter.date(from: user.dobString.value)!
        self.datePicker.date = self.selectedDob
        
        self.selectedGender = user.gender ?? Gender.male
    
        self.postcodeFieldView.textField.text = (user.postcode.value == "<null>") ? "" : user.postcode.value
        
        self.updateDobField()
        self.updateGenderField()
        
        if self.signupProvider == .facebook || self.signupProvider == .instagram {
            let largeAttributes = [NSAttributedStringKey.font : UIFont.appBoldFontOf(size: 14.0),
                                   NSAttributedStringKey.foregroundColor : UIColor.white]
            let smallAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 12.0),
                                   NSAttributedStringKey.foregroundColor : UIColor.white]
            
            let provider = self.signupProvider == .instagram ? "Instagram" : "Facebook"
            let attributedName = NSAttributedString(string: user.fullName.value, attributes: largeAttributes)
            let attributedInfo = NSAttributedString(string: " Connected with \(provider)", attributes: smallAttributes)
            
            let attributedString = NSMutableAttributedString()
            attributedString.append(attributedName)
            attributedString.append(attributedInfo)
            self.loginInfoLabel.attributedText = attributedString
        } else {
            self.loginInfoLabel.text = user.fullName.value
        }
               
        if let profileImageUrl = user.profileImage.value {
            let url = URL(string: profileImageUrl)
            
            self.profileImageView.setImageWith(url: url, showRetryButton: true, placeHolder: UIImage(named: "profile_placeholder"), shouldShowAcitivityIndicator: true, shouldShowProgress: false, refreshCache: true, completion: nil)
            
        } else {
            self.profileImageView.image = UIImage(named: "profile_placeholder")
        }
        
        if showSuccessAlert {
            self.showAlertController(title: "", msg: "Record has been updated successfully.")
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
    
    @objc func textFieldDidEndOnExit(sender: UITextField) {
        if sender == self.fullNameFieldView.textField {
            self.dobFieldView.textField.becomeFirstResponder()
        } else if sender == self.currentPasswordFieldView.textField {
            self.passwordFieldView.textField.becomeFirstResponder()
        } else if sender == self.passwordFieldView.textField {
            self.confirmPasswordFieldView.textField.becomeFirstResponder()
        }
    }
    
    func isUpdatingPassword() -> Bool {
        return self.passwordFieldView.textField.text!.count > 0 || self.confirmPasswordFieldView.textField.text!.count > 0 || self.currentPasswordFieldView.textField.text!.count > 0
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if self.fullNameFieldView.textField.text!.trimWhiteSpaces().count < 2 {
            isValid = false
            self.fullNameFieldView.showValidationMessage(message: "Please enter your name.")
        } else {
            self.fullNameFieldView.reset()
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
        
        if self.postcodeFieldView.textField.text! == "" {
            
        } else if !self.postcodeFieldView.textField.text!.uppercased().isValidPostCode() {
            isValid = false
            self.postcodeFieldView.showValidationMessage(message: "Please enter valid postcode.")
        } else {
            self.postcodeFieldView.reset()
        }
        
        if self.isUpdatingPassword() {
            
            if self.currentPasswordFieldView.textField.text! == "" {
                isValid = false
                self.currentPasswordFieldView.showValidationMessage(message: "This field is required.")
            } else if self.currentPasswordFieldView.textField.text!.count < 8 {
                isValid = false
                self.currentPasswordFieldView.showValidationMessage(message: "Please enter password of atleast 8 characters.")
            } else {
                self.currentPasswordFieldView.reset()
            }
            
            if self.passwordFieldView.textField.text! == "" {
                isValid = false
                self.passwordFieldView.showValidationMessage(message: "This field is required.")
            } else if self.passwordFieldView.textField.text!.count < 8 {
                isValid = false
                self.passwordFieldView.showValidationMessage(message: "Please enter password of atleast 8 characters.")
            } else {
                self.passwordFieldView.reset()
            }
            
            if self.confirmPasswordFieldView.textField.text! == "" {
                isValid = false
                self.confirmPasswordFieldView.showValidationMessage(message: "This field is required.")
            } else if self.confirmPasswordFieldView.textField.text! != self.passwordFieldView.textField.text! {
                isValid = false
                self.confirmPasswordFieldView.showValidationMessage(message: "Password and confirm password mismatched.")
            } else {
                self.confirmPasswordFieldView.reset()
            }
            
        } else {
            self.passwordFieldView.reset()
            self.confirmPasswordFieldView.reset()
        }
        
        return isValid
    }

    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
            self.fullNameFieldView.textField.becomeFirstResponder()
        }
    }
    
    @IBAction func datePickerValueChanged(sender: UIDatePicker) {
        self.selectedDob = sender.date
        self.updateDobField()
    }
    
    @IBAction func updateButtonTapped(sender: UIButton) {
        Analytics.logEvent(updateAccountSettings, parameters: nil)
        
        if self.isDataValid() {
            self.view.endEditing(true)
            self.updateUserProfile()
        }
    }

    @IBAction func socialLogoutButtonTapped(sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut()
        
        self.setUpUserProfile()
    }
}

//MARK: UIPickerViewDelegate, UIPickerViewDataSource
extension AccountSettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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

//MARK: FieldViewDelegate
extension AccountSettingsViewController: FieldViewDelegate {
    
    func fieldView(fieldView: FieldView, didBeginEditing textField: UITextField) {
        if textField == self.genderFieldView.textField {
            self.updateGenderField()
            if let index = self.genders.firstIndex(of: self.selectedGender) {
                self.pickerView.selectRow(index, inComponent: 0, animated: true)
            }
            
        } else if textField == self.dobFieldView.textField {
            self.updateDobField()
        }
    }
    
    func fieldView(fieldView: FieldView, didEndEditing textField: UITextField) {
        
    }
    
    func fieldView(fieldView: FieldView, shouldChangeCharactersIn range: NSRange, replacementString string: String, textField: UITextField) -> Bool {
          
          if fieldView == self.postcodeFieldView {
              let maxLength = 8
              let currentString: NSString = textField.text! as NSString
              let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
              return newString.length <= maxLength
          }

          return true
      }
    
}

//MARK: Webservices Methods
extension AccountSettingsViewController {
    func updateUserProfile() {
        
        let dob = Utility.shared.serverDateFormattedString(date: self.selectedDob)
        
        var params = ["full_name" : self.fullNameFieldView.textField.text!,
                      "date_of_birth" : dob]
        
        params["gender"] = self.selectedGender.rawValue
        params["postcode"] = self.postcodeFieldView.textField.text!.uppercased()

        if isUpdatingPassword() {
            params["old_password"] = self.currentPasswordFieldView.textField.text!
            params["new_password"] = self.passwordFieldView.textField.text!
        }
        
        self.updateButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let apiPath = apiPathUserProfileUpdate + "/\(Utility.shared.getCurrentUser()!.userId.value)"
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPath, method: .put) { (response, serverError, error) in
            self.updateButton.hideLoader()
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
            if let responseData = (responseDict?["data"] as? [String : Any]) {
                
                try! CoreStore.perform(synchronous: { (transaction) -> Void in
                    let editedUser = transaction.edit(Utility.shared.getCurrentUser())
                    editedUser?.fullName.value = "\(responseData["full_name"]!)"
                    editedUser?.dobString.value = "\(responseData["date_of_birth"]!)"
                    editedUser?.genderString.value = "\(responseData["gender"]!)"
                    if let postcode = responseData["postcode"] {
                        editedUser?.postcode.value = "\(postcode)"
                    }
                })
                
                self.setUpUserProfile(showSuccessAlert: true)
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
        
    }
}
