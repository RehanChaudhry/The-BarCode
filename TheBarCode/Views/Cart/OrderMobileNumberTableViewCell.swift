//
//  OrderMobileNumberTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderMobileNumberTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var notesLabel: UILabel!
    
    @IBOutlet var selectionView: UIView!
    
    var mobileModel: OrderMobileNumber!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        
    }
    
    func setupCell(mobileModel: OrderMobileNumber) {

        self.mobileModel = mobileModel
        
        self.selectionView.isHidden = !mobileModel.isDefault
        
        self.textField.text = mobileModel.text
        self.placeholderLabel.text = mobileModel.placeholder
        self.notesLabel.attributedText = mobileModel.note
        
        self.showSeparator(show: false)
    }
        
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
    
    //MARK: My IBActions
    @IBAction func textFieldTextDidChange(sender: UITextField) {
        self.mobileModel.text = sender.text ?? ""
    }
    
    @IBAction func markDefaultButtonTapped(sender: UIButton) {
        self.mobileModel.isDefault = !self.mobileModel.isDefault
        self.setupCell(mobileModel: self.mobileModel)
    }
}

//MARK: UITextFieldDelegate
extension OrderMobileNumberTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = self.mobileModel.allowedCharacters
        let replacementStringIsLegal = allowedCharacterSet == nil ? false : string.rangeOfCharacter(from: allowedCharacterSet!) == nil
        
        if replacementStringIsLegal && string.count > 0 {
            return false
        } else {
            let maxLength = 13
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }
}

