//
//  ReferralViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

class ReferralViewController: UIViewController {

    @IBOutlet var separatorView: UIView!
    
    var codeFieldView: FieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationItem.hidesBackButton = true
        self.setUpFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.view.addSubview(self.codeFieldView)
        
        self.codeFieldView.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self.separatorView, withOffset: 24.0)
        self.codeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.codeFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.codeFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
    }
    
    func isDataValid() -> Bool {
        var isValid = true
        
        if self.codeFieldView.textField.text!.count < 6 {
            isValid = false
            self.codeFieldView.showValidationMessage(message: "Please enter 7 characters invite code.")
        } else {
            self.codeFieldView.reset()
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
            self.performSegue(withIdentifier: "ReferralToCategories", sender: nil)
        }
    }
    
}
