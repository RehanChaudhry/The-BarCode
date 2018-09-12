//
//  ForgotPasswordViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

class ForgotPasswordViewController: UIViewController {

    @IBOutlet var separatorView: UIView!
    
    var emailFieldView: FieldView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    
    //MARK: My IBActions
    
    @IBAction func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func forgotPasswordButtonTapped(sender: UIButton) {
        
    }

}
