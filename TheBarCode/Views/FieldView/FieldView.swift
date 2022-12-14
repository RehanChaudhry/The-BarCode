//
//  FieldView.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

@objc protocol FieldViewDelegate: class {
    @objc optional func fieldView(fieldView: FieldView, didBeginEditing textField: UITextField)
    @objc optional func fieldView(fieldView: FieldView, didEndEditing textField: UITextField)
    
    @objc optional func fieldView(fieldView: FieldView, shouldChangeCharactersIn range: NSRange, replacementString string: String, textField: UITextField) -> Bool
}

class FieldView: UIView, NibReusable {

    @IBOutlet var prefixLabel: UILabel!
    
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var validationLabel: UILabel!

    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var prefixLabelMargin: NSLayoutConstraint!
    @IBOutlet var prefixLabelWidth: NSLayoutConstraint!
    @IBOutlet var placeholderLabelLeft: NSLayoutConstraint!
    
    @IBOutlet var validationLabelLeft: NSLayoutConstraint!
    @IBOutlet var validationLabelRight: NSLayoutConstraint!
    @IBOutlet var placeholderLabelHeight: NSLayoutConstraint!
    @IBOutlet var validationLabelHeight: NSLayoutConstraint!
    
    @IBOutlet var fieldLeft: NSLayoutConstraint!
    @IBOutlet var fieldRight: NSLayoutConstraint!
    
    @IBOutlet var iconWidth: NSLayoutConstraint!
    
    @IBOutlet weak var sampleTextLabel: UILabel!
    
    @IBOutlet var flagView: UIView!
    @IBOutlet var flagImageView: UIImageView!
    
    weak var delegate: FieldViewDelegate?
    
    var borders: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textField.keyboardAppearance = .dark
        self.textField.textColor = UIColor.white
        self.textField.returnKeyType = .default
        self.textField.delegate = self
        
        self.placeholderLabel.font = UIFont.appBoldFontOf(size: self.placeholderLabel.font.pointSize)
        self.placeholderLabel.textColor = UIColor.white
        self.borders = self.textField.addBorders(edges: .bottom, color: UIColor.appFieldBottomBorderColor() , thickness: 1.0)
        
        self.prefixLabel.addBorders(edges: .bottom, color: UIColor.appFieldBottomBorderColor(), thickness: 1.0)
        
        self.sampleTextLabel.isHidden = true

        
    }
    
    //MARK: My Methods
    
    func removeBorders() {
        for border in borders {
            border.removeFromSuperview()
        }
    }
    
    func makeSecure(secure: Bool) {
        self.textField.isSecureTextEntry = secure
    }
    
    func setReturnKey(returnKey: UIReturnKeyType) {
        self.textField.returnKeyType = returnKey
    }
    
    func reset() {
        self.validationLabel.isHidden = true
    }
    
    func setUpFieldView(placeholder: String = "", fieldPlaceholder: String, iconImage: UIImage? = nil) {
        
        self.reset()
        
        let placeholderTextColor = UIColor.appGrayColor()
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
    
    func setUpFieldViewWithSampleText(placeholder: String = "", sampleText: String, fieldPlaceholder: String, iconImage: UIImage? = nil) {
        
        self.reset()
        
        let placeholderTextColor = UIColor.appGrayColor()
        let placeholderAttributes = [NSAttributedStringKey.foregroundColor : placeholderTextColor,
                                     NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 15.0)]
        let attributedPlaceholder = NSAttributedString(string: fieldPlaceholder, attributes: placeholderAttributes)
        
        self.textField.attributedPlaceholder = attributedPlaceholder
        self.placeholderLabel.text = placeholder

        self.sampleTextLabel.isHidden = false
        self.sampleTextLabel.text = sampleText
        
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

//MARK: UITextFieldDelegate
extension FieldView: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        for border in borders {
            border.backgroundColor = UIColor.white
        }
        
        self.delegate?.fieldView?(fieldView: self, didBeginEditing: self.textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for border in borders {
            border.backgroundColor = UIColor.appFieldBottomBorderColor()
        }
        
        self.delegate?.fieldView?(fieldView: self, didEndEditing: self.textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.delegate?.fieldView?(fieldView: self, shouldChangeCharactersIn: range, replacementString: string, textField: self.textField) ?? true
    }
    
}
