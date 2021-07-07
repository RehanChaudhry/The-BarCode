//
//  OrderDineInFieldTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderDineInFieldTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var currencySymbol: UILabel!
    @IBOutlet var textField: UITextField!
    @IBOutlet weak var backGroundView: UIView!
    
    var orderField: OrderFieldInput!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setUpCell(orderField: OrderFieldInput) {
    
        self.backGroundView.layer.cornerRadius = 8;
        self.backGroundView.layer.masksToBounds = true;
        self.currencySymbol.text = orderField.currencySymbol
        self.textField.text = orderField.text
        self.textField.placeholder = orderField.placeholder
        self.textField.keyboardType = orderField.keyboardType
        
        self.showSeparator(show: false)
        
        self.orderField = orderField
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
        self.orderField.text = sender.text ?? ""
    }
    
    
}

//MARK: UITextFieldDelegate
extension OrderDineInFieldTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = self.orderField.allowedCharacterSet
        let replacementStringIsLegal = allowedCharacterSet == nil ? false : string.rangeOfCharacter(from: allowedCharacterSet!) == nil
        
        if replacementStringIsLegal && string.count > 0 {
            return false
        } else {
            let maxLength = self.orderField.maxCharacters
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }
    }
}
