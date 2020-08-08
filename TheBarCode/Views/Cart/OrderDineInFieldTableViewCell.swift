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

    @IBOutlet var textField: UITextField!
    
    var orderField: OrderDineInField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setUpCell(orderField: OrderDineInField) {
        self.textField.text = orderField.text
        
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
        self.orderField.text = sender.text ?? ""
    }
    
    
}
