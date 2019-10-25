//
//  ReferralViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import CoreStore
import CoreLocation

class ReferralViewController: UIViewController {

    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var referralButton: GradientButton!
    
    var codeFieldView: FieldView!
    
    var characterLimit = 7
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationItem.hidesBackButton = true
        self.setUpFields()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let referralCode = appDelegate.referralCode {
            self.codeFieldView.textField.text = referralCode
            appDelegate.referralCode = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        debugPrint("ReferralViewController deinit called")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        if segue.identifier == "ReferralToCategories" {
            let categoriesViewController = segue.destination as! CategoriesViewController
            categoriesViewController.isUpdating = false
        }
    }
    
    //MARK: My Methods
    
    func setUpFields() {
        self.codeFieldView = FieldView.loadFromNib()
        self.codeFieldView.setUpFieldView(placeholder: "REFERRAL CODE", fieldPlaceholder: "Enter 7 characters referral/invite code", iconImage: nil)
        self.codeFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.codeFieldView.delegate = self
        self.view.addSubview(self.codeFieldView)
        
        self.codeFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.separatorView, withOffset: 24.0)
        self.codeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.codeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.codeFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if self.codeFieldView.textField.text!.count == characterLimit {
            self.codeFieldView.reset()
        } else {
            isValid = false
            self.codeFieldView.showValidationMessage(message: "Please enter \(characterLimit) characters invite code.")
        }
        
        return isValid
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        
        self.codeFieldView.textField.resignFirstResponder()
    }
    
    //MARK: My IBActions
    
    @IBAction func skipButtonTapped(sender: UIButton) {
        self.performSegue(withIdentifier: "ReferralToCategories", sender: nil)
    }
    
    @IBAction func continuePasswordButtonTapped(sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.isDataValid() {
            self.referral()
        }
    }
    
}

//MARK: FieldViewDelegate
extension ReferralViewController: FieldViewDelegate {
    func fieldView(fieldView: FieldView, shouldChangeCharactersIn range: NSRange, replacementString string: String, textField: UITextField) -> Bool {
        let maxLength = self.characterLimit
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

//MARK: Webservices Methods
extension ReferralViewController {
    func referral() {
        let referralCode = self.codeFieldView.textField.text!
        let params = ["own_referral_code" : referralCode]
        
        self.referralButton.showLoader()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathReferral, method: .put) { (response, serverError, error) in
            
            self.referralButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "Referral", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "Referral", msg: serverError!.errorMessages())
                return
            }
            
            let currentUser = Utility.shared.getCurrentUser()!
            try! CoreStore.perform(synchronous: { (transaction) -> Void in
                let editedUser = transaction.edit(currentUser)
                editedUser?.referralCode.value = referralCode
            })
            
            if !currentUser.isCategorySelected.value {
                self.performSegue(withIdentifier: "ReferralToCategories", sender: nil)
            } else if CLLocationManager.authorizationStatus() == .notDetermined {
                self.performSegue(withIdentifier: "SignInToPermissionSegue", sender: nil)
            } else {
                let tabbarController = self.storyboard?.instantiateViewController(withIdentifier: "TabbarController")
                self.navigationController?.present(tabbarController!, animated: true, completion: {
                    let loginOptions = self.navigationController?.viewControllers[1] as! LoginOptionsViewController
                    self.navigationController?.popToViewController(loginOptions, animated: false)
                })
            }
            
        }
    }
}
