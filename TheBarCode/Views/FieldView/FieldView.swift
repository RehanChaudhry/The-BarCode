//
//  FieldView.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FieldView: UIView, NibReusable {

    @IBOutlet var textField: UITextField!
    
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var validationLabel: UILabel!

    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var placeholderLabelLeft: NSLayoutConstraint!
    
    @IBOutlet var validationLabelLeft: NSLayoutConstraint!
    @IBOutlet var validationLabelRight: NSLayoutConstraint!
    
    @IBOutlet var fieldLeft: NSLayoutConstraint!
    @IBOutlet var fieldRight: NSLayoutConstraint!
    
    @IBOutlet var iconWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textField.returnKeyType = .default
        
        self.placeholderLabel.textColor = UIColor.appGrayColor()
        self.textField.textColor = UIColor.appGrayColor()
        self.textField.addBorders(edges: .bottom, color: UIColor.appGrayColor() , thickness: 1.0)
    }
    
    //MARK: My Methods
    
    func setReturnKey(returnKey: UIReturnKeyType) {
        self.textField.returnKeyType = returnKey
    }
    
    func reset() {
        self.validationLabel.isHidden = true
    }
    
    func setUpFieldView(placeholder: String = "", fieldPlaceholder: String, iconImage: UIImage? = nil) {
        
        self.reset()
        
        let placeholderTextColor = UIColor.appGrayColor().withAlphaComponent(0.2)
        let placeholderAttributes = [NSAttributedStringKey.foregroundColor : placeholderTextColor,
                                     NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 15.0)]
        let attributedPlaceholder = NSAttributedString(string: fieldPlaceholder, attributes: placeholderAttributes)
        
        self.textField.attributedPlaceholder = attributedPlaceholder
        self.placeholderLabel.text = placeholder
        
        self.iconImageView.image = iconImage
        if let _ = iconImage {
            self.iconWidth.constant = 16.0
            self.layoutIfNeeded()
        } else {
            self.iconWidth.constant = 0.0
            
            self.layoutIfNeeded()
        }
    }
    
    func setKeyboardType(keyboardType: UIKeyboardType = .default, inputView: UIView? = nil) {
        
        self.textField.inputView = inputView
        self.textField.keyboardType = keyboardType
    }
    
    func showValidationMessage(message: String) {
        
        self.validationLabel.text = message
        self.validationLabel.isHidden = false
    }
}
