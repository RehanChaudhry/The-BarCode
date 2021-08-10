//
//  OrderDetailsPhoneTableViewCell.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 09/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol OrderDetailsPhoneTableViewCellDelegate: class {
   
    func orderDetailsPhoneTableViewCell(cell: OrderDetailsPhoneTableViewCell, phoneNumberTapped sender: UIButton)
   
}

class OrderDetailsPhoneTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var headingPhoneNumberLabel: UILabel!
    
    @IBOutlet weak var phoneNumberButton: UIButton!
    
    weak var delegate: OrderDetailsPhoneTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(orderDetailPhoneNumber: OrderDetailPhoneNumber) {

        self.headingPhoneNumberLabel.text = orderDetailPhoneNumber.headingPhoneNumber
        
        if orderDetailPhoneNumber.titlePhoneNumber == "" {
            self.phoneNumberButton.isHidden = true
            self.phoneNumberButton.isHidden = true
            //self.phoneNumberButton.constant = 0.0
            self.phoneNumberButton.setTitle("", for: .normal)
        } else {
            self.phoneNumberButton.isHidden = false
            self.phoneNumberButton.isHidden = false
            //self.phoneNumberButton.constant = 40.0
            self.phoneNumberButton.setTitle(orderDetailPhoneNumber.titlePhoneNumber, for: .normal)
        }
        
    }
    
    @IBAction func phoneNumberTapped(_ sender: UIButton) {
        
        self.delegate?.orderDetailsPhoneTableViewCell(cell: self, phoneNumberTapped: sender)
    }
}
