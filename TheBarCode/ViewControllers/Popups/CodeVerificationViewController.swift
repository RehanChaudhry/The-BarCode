//
//  CodeVerificationViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class CodeVerificationViewController: UIViewController {

    @IBOutlet var hiddenField: UITextField!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var actionButton: GradientButton!
    
    @IBOutlet var codeFieldContainer1: UIView!
    @IBOutlet var codeFieldContainer2: UIView!
    @IBOutlet var codeFieldContainer3: UIView!
    @IBOutlet var codeFieldContainer4: UIView!
    
    @IBOutlet var popUpTopMargin: NSLayoutConstraint!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    
    var codeFieldView1: FieldView!
    var codeFieldView2: FieldView!
    var codeFieldView3: FieldView!
    var codeFieldView4: FieldView!
    
    var maxLength = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if UIScreen.main.bounds.size.height <= 568.0 {
            self.popUpTopMargin.constant = 30.0
        }
        
        self.actionButton.isEnabled = false
        
        self.setUpFieldViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hiddenField.becomeFirstResponder()
    }

    //MARK: My Methods
    
    func setUpFieldViews() {
        self.codeFieldView1 = FieldView.loadFromNib()
        self.codeFieldView1.textField.isEnabled = false
        self.codeFieldView1.makeSecure(secure: true)
        self.codeFieldView1.fieldLeft.constant = 0.0
        self.codeFieldView1.fieldRight.constant = 0.0
        self.codeFieldView1.placeholderLabelHeight.constant = 0.0
        self.codeFieldView1.validationLabelHeight.constant = 0.0
        self.codeFieldView1.setUpFieldView(fieldPlaceholder: "X")
        self.codeFieldView1.textField.textAlignment = .center
        self.codeFieldContainer1.addSubview(self.codeFieldView1)
        self.codeFieldView1.autoPinEdgesToSuperviewEdges()
        
        self.codeFieldView2 = FieldView.loadFromNib()
        self.codeFieldView2.textField.isEnabled = false
        self.codeFieldView2.makeSecure(secure: true)
        self.codeFieldView2.fieldLeft.constant = 0.0
        self.codeFieldView2.fieldRight.constant = 0.0
        self.codeFieldView2.placeholderLabelHeight.constant = 0.0
        self.codeFieldView2.validationLabelHeight.constant = 0.0
        self.codeFieldView2.setUpFieldView(fieldPlaceholder: "X")
        self.codeFieldView2.textField.textAlignment = .center
        self.codeFieldContainer2.addSubview(self.codeFieldView2)
        self.codeFieldView2.autoPinEdgesToSuperviewEdges()
        
        self.codeFieldView3 = FieldView.loadFromNib()
        self.codeFieldView3.textField.isEnabled = false
        self.codeFieldView3.makeSecure(secure: true)
        self.codeFieldView3.fieldLeft.constant = 0.0
        self.codeFieldView3.fieldRight.constant = 0.0
        self.codeFieldView3.placeholderLabelHeight.constant = 0.0
        self.codeFieldView3.validationLabelHeight.constant = 0.0
        self.codeFieldView3.setUpFieldView(fieldPlaceholder: "X")
        self.codeFieldView3.textField.textAlignment = .center
        self.codeFieldContainer3.addSubview(self.codeFieldView3)
        self.codeFieldView3.autoPinEdgesToSuperviewEdges()
        
        self.codeFieldView4 = FieldView.loadFromNib()
        self.codeFieldView4.textField.isEnabled = false
        self.codeFieldView4.makeSecure(secure: true)
        self.codeFieldView4.fieldLeft.constant = 0.0
        self.codeFieldView4.fieldRight.constant = 0.0
        self.codeFieldView4.placeholderLabelHeight.constant = 0.0
        self.codeFieldView4.validationLabelHeight.constant = 0.0
        self.codeFieldView4.setUpFieldView(fieldPlaceholder: "X")
        self.codeFieldView4.textField.textAlignment = .center
        self.codeFieldContainer4.addSubview(self.codeFieldView4)
        self.codeFieldView4.autoPinEdgesToSuperviewEdges()
    }
    
    func resetField() {
        self.codeFieldView1.textField.text = ""
        self.codeFieldView2.textField.text = ""
        self.codeFieldView3.textField.text = ""
        self.codeFieldView4.textField.text = ""
    }
    
    //MARK: IBActions
    @IBAction func textFieldTextDidChanged(_ sender: Any) {
        
        let text = hiddenField.text!
        self.resetField()
        
        for (index, char) in text.enumerated() {
            if index == 0 {
                self.codeFieldView1.textField.text = "\(char)"
            } else if index == 1 {
                self.codeFieldView2.textField.text = "\(char)"
            } else if index == 2 {
                self.codeFieldView3.textField.text = "\(char)"
            } else if index == 3 {
                self.codeFieldView4.textField.text = "\(char)"
            } else {
                break
            }
        }
        
        self.actionButton.isEnabled = text.count >= self.maxLength
    }
    
    //MARK: My IBActions
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: UITextFieldDelegate
extension CodeVerificationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
