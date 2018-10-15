//
//  EmailVerificationViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

protocol EmailVerificationViewControllerDelegate: class {
    func userVerifiedSuccessfully()
}

class EmailVerificationViewController: CodeVerificationViewController {

    @IBOutlet var resendCodeButton: UIButton!
    
    var delegate: EmailVerificationViewControllerDelegate!
    
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let subTitlePlaceholder = "Enter the confirmation code here which we have sent you on "
        let subTitleText = subTitlePlaceholder + self.email
        
        let normalAttribute = [NSAttributedStringKey.foregroundColor : self.titleLabel.textColor,
                               NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 16.0)]
        let boldAttribute = [NSAttributedStringKey.foregroundColor : UIColor.appBlueColor(),
                             NSAttributedStringKey.font : UIFont.appBoldFontOf(size: 16.0)]
        
        let attributedSubTitle = NSMutableAttributedString(string: subTitleText)
        attributedSubTitle.addAttributes(normalAttribute as [NSAttributedStringKey : Any], range: (subTitleText as NSString).range(of: subTitlePlaceholder))
        attributedSubTitle.addAttributes(boldAttribute  as [NSAttributedStringKey : Any], range: (subTitleText as NSString).range(of: self.email))
        
        self.subTitleLabel.attributedText = attributedSubTitle
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerHeight.constant = 274.0 + self.subTitleLabel.frame.height
    }
    
    //MARK: My IBActions
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        self.verifyCurrentUser()
    }
    
    @IBAction func resendCodeButtonTapped(sender: UIButton) {
        self.resendCode()
    }

}

//MARK: Webservices Methods
extension EmailVerificationViewController {
    func verifyCurrentUser() {
        let params = ["email" : self.email!,
                      "activation_code" : self.hiddenField.text!]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathEmailVerification, method: .post) { (response, serverError, error) in
            
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
                
                let _ = Utility.shared.saveCurrentUser(userDict: responseUser)

                self.dismiss(animated: true, completion: {
                    self.delegate.userVerifiedSuccessfully()
                })
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
    }
    
    func resendCode() {
        let params = ["email" : self.email!]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathResendVerificationEmail, method: .post) { (response, serverError, error) in
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            self.showAlertController(title: "Verification Code Resent", msg: "Email containing verfication code has been sent on \(self.email!)")
            
        }
    }
}
