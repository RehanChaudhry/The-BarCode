//
//  OrderDetailsPhoneTableViewCell.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 09/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderDetailsPhoneTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var headingPhoneNumberLabel: UILabel!
    @IBOutlet weak var titlePhoneNumberLabel: UILabel!
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
        
        self.titlePhoneNumberLabel.text = orderDetailPhoneNumber.titlePhoneNumber
        
    }
    
}
