//
//  OrderPaymentTableViewCell.swift
//  TheBarCode
//
//  Created by Macbook on 21/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderPaymentTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var mainView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var paymentLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.mainView.layer.cornerRadius = 8

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(orderPaymentInfo: OrderPaymentInfo) {

        self.mainView.layer.cornerRadius = 8

        self.nameLabel.text = orderPaymentInfo.title
        self.paymentLabel.text = orderPaymentInfo.status + "(\(orderPaymentInfo.percentage)%)"
        
        let priceString = String(format: "%.2f", orderPaymentInfo.price)
        self.priceLabel.text =  "£ " + priceString

    }

}
