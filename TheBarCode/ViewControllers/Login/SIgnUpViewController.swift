//
//  SIgnUpViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

class SIgnUpViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var fbSignUpView: UIView!
    
    @IBOutlet var fbSignUpButton: UIButton!
    
    @IBOutlet var termsPolicyTextView: UITextView!
    
    @IBOutlet var contentHeight: NSLayoutConstraint!
    
    var fullNameFieldView: FieldView!
    var emailFieldView: FieldView!
    var passwordFieldView: FieldView!
    var dobFieldView: FieldView!
    var genderFieldView: FieldView!
    
    let termsScheme = "thebarcode://terms"
    let policyScheme = "thebarcode://policy"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        self.contentView.addSubview(self.fullNameFieldView)
        
        self.fullNameFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fbSignUpView, withOffset: 5.0)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.fullNameFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.fullNameFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter your email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.contentView.addSubview(self.emailFieldView)
        
        self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.fullNameFieldView, withOffset: 5.0)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.passwordFieldView = FieldView.loadFromNib()
        self.passwordFieldView.setUpFieldView(placeholder: "PASSWORD", fieldPlaceholder: "Create your account password", iconImage: nil)
        self.passwordFieldView.setKeyboardType()
        self.contentView.addSubview(self.passwordFieldView)
        
        self.passwordFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.emailFieldView, withOffset: 5.0)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.passwordFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.passwordFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.dobFieldView = FieldView.loadFromNib()
        self.dobFieldView.fieldRight.constant = 8.0
        self.dobFieldView.validationLabelRight.constant = 8.0
        self.dobFieldView.setUpFieldView(placeholder: "DATE OF BIRTH", fieldPlaceholder: "DD/MM/YYYY", iconImage: #imageLiteral(resourceName: "icon_calendar"))
        self.dobFieldView.setKeyboardType(inputView: nil)
        self.contentView.addSubview(self.dobFieldView)
        
        self.dobFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
        self.dobFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.dobFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView = FieldView.loadFromNib()
        self.genderFieldView.fieldLeft.constant = 8.0
        self.genderFieldView.validationLabelLeft.constant = 8.0
        self.genderFieldView.placeholderLabelLeft.constant = 8.0
        self.genderFieldView.setUpFieldView(placeholder: "GENDER", fieldPlaceholder: "Select gender", iconImage: #imageLiteral(resourceName: "icon_dropdown"))
        self.genderFieldView.setKeyboardType(inputView: nil)
        self.contentView.addSubview(self.genderFieldView)
        
        self.genderFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.passwordFieldView, withOffset: 5.0)
        self.genderFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.genderFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.genderFieldView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: self.dobFieldView)
        self.genderFieldView.autoMatch(ALDimension.width, to: ALDimension.width, of: self.dobFieldView)

        let navbarHeight = self.navigationController!.navigationBar.frame.size.height
        let statusBarHeight = UIApplication.shared.statusBarFrame.height

        let rowCount = 5.0
        self.contentHeight.constant = CGFloat(71.0 * rowCount) + 2.0 + self.fbSignUpView.frame.height - navbarHeight - statusBarHeight
        
        self.view.layoutIfNeeded()
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
                              NSAttributedStringKey.font.rawValue : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.underlineColor.rawValue : UIColor.appBlueColor(),
                              NSAttributedStringKey.underlineStyle.rawValue : NSUnderlineStyle.styleSingle.rawValue] as [String : Any]
        self.termsPolicyTextView.linkTextAttributes = linkAttributes
        
        self.termsPolicyTextView.attributedText = attributedTermsAndPolicy
    }
    
    //MARK: My IBActions
    
    @IBAction func fbSignUpButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func createAccountButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "SignUpToReferralSegue", sender: nil)
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
