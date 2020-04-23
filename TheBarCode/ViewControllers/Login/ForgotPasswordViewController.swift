//
//  ForgotPasswordViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import ObjectMapper
import FirebaseAnalytics

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var forgotPasswordButton: GradientButton!
    
    var emailFieldView: FieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        
        self.addBackButton()
        self.setUpFields()
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
        self.view.addSubview(self.emailFieldView)
        
        self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.separatorView, withOffset: 24.0)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
    }
    
    func isDataValid() -> Bool {
        
        var isValid = true
        
        if self.emailFieldView.textField.text! == "" {
            isValid = false
            self.emailFieldView.showValidationMessage(message: "Email field is required.")
        } else  if !self.emailFieldView.textField.text!.isValidEmail() {
            isValid = false
            self.emailFieldView.showValidationMessage(message: "Please enter valid email address.")
        } else {
            self.emailFieldView.reset()
        }
        
        return isValid
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        
        self.emailFieldView.textField.resignFirstResponder()
    }
    
    //MARK: My IBActions
    
    @IBAction func backButtonTapped(sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordButtonTapped(sender: UIButton) {
        
        Analytics.logEvent(forgotPasswordRequest, parameters: nil)
        self.view.endEditing(true)
        
        if self.isDataValid() {
            self.forgotPassword()
        }
    }

}

//MARK: Websercices Methods
extension ForgotPasswordViewController {
    
    func forgotPassword() {
        
        self.forgotPasswordButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let params = ["email" : self.emailFieldView.textField.text!]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathForgotPassword, method: .post) { (response, serverError, error) in
        
            self.forgotPasswordButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "Forgot Password", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "Forgot Password", msg: serverError!.errorMessages())
                return
            }
            
            var message: String = "An email with instructions about how to reset your password has been sent. Please follow the instructions to reset your password."
            if let responseDict = response as? [String : Any] {
                let serverMessage = Mapper<ServerMessage>().map(JSON: responseDict)
                message = serverMessage!.message
            }
            
            let alertController = UIAlertController(title: "Forgot Password", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel) { (action) in
                self.navigationController?.popViewController(animated: true)
            })
            self.present(alertController, animated: true, completion: nil)
            

        }
        
    }
    
}
