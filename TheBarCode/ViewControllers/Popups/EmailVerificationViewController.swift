//
//  EmailVerificationViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import ObjectMapper
import FirebaseAnalytics

protocol EmailVerificationViewControllerDelegate: class {
    func userVerifiedSuccessfully(canShowReferral: Bool)
}

class EmailVerificationViewController: CodeVerificationViewController {

    @IBOutlet weak var gradientTitleView: GradientView!

    @IBOutlet var resendCodeButton: LoadingButton!
    
    var delegate: EmailVerificationViewControllerDelegate!
    
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.resendCodeButton.updateAcivityIndicatorColor(color: UIColor.appBlackColor())
        
        let subTitlePlaceholder = "Enter the activation code here which we have sent you on "
        let subTitleText = subTitlePlaceholder + self.email
        let infoText = "\n\nIf you don't receive an email, you can always use SMS."
        
        let normalAttribute = [NSAttributedStringKey.foregroundColor : UIColor.appBlackColor(),
                               NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 16.0)]
        let boldAttribute = [NSAttributedStringKey.foregroundColor : UIColor.appBlueColor(),
                             NSAttributedStringKey.font : UIFont.appBoldFontOf(size: 16.0)]
        let smallAttribute = [NSAttributedStringKey.foregroundColor : UIColor.appBlackColor(),
                               NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 12.0)]
        
        let attributedSubTitle = NSMutableAttributedString(string: subTitleText)
        attributedSubTitle.addAttributes(normalAttribute as [NSAttributedStringKey : Any], range: (subTitleText as NSString).range(of: subTitlePlaceholder))
        attributedSubTitle.addAttributes(boldAttribute  as [NSAttributedStringKey : Any], range: (subTitleText as NSString).range(of: self.email))
        
        let attributedInfoText = NSAttributedString(string: infoText, attributes: smallAttribute)
        attributedSubTitle.append(attributedInfoText)
        
        self.subTitleLabel.attributedText = attributedSubTitle
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
        
        self.hiddenField.keyboardType = .numberPad
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.containerHeight.constant = self.resendCodeButton.frame.origin.y + self.resendCodeButton.frame.size.height + 16.0
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
        
        self.actionButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathEmailVerification, method: .post) { (response, serverError, error) in
        
            self.actionButton.hideLoader()
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

                Analytics.logEvent(createAccountViaEmail, parameters: nil)

                self.dismiss(animated: true, completion: {
                    self.delegate.userVerifiedSuccessfully(canShowReferral: true)
                })
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
    }
    
    func resendCode() {
        let params = ["email" : self.email!]
        
        self.resendCodeButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathResendVerificationEmail, method: .post) { (response, serverError, error) in
            
            self.resendCodeButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            if let responseDict = response as? [String : Any] {
                let serverMessage = Mapper<ServerMessage>().map(JSON: responseDict)
                self.showAlertController(title: "Verification Code", msg: serverMessage!.message)
            } else {
                self.showAlertController(title: "Verification Code", msg: "Email containing verfication code has been sent on \(self.email!)")
            }
        }
    }
}
