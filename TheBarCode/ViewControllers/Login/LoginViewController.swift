//
//  LoginViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

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

    //MARK: My IBActions
    
    @IBAction func fbSignInButtonTapped(sender: UIButton) {
        
    }
    
    @IBAction func signInButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        
        if self.isDataValid() {
            let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
            self.navigationController?.present(tabbarController!, animated: true, completion: {
                let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                self.navigationController?.popToViewController(loginOptions, animated: false)
            })
        }
    }

}
