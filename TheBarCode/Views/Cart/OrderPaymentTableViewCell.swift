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
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 2000, 0.0, 0.0)
        }
    }
    
    func setupCell(orderPaymentInfo: OrderPaymentInfo, showSeparator: Bool) {

        self.mainView.layer.cornerRadius = 8

        self.nameLabel.text = orderPaymentInfo.title
        
        if orderPaymentInfo.status == .paid {
            self.paymentLabel.textColor = UIColor.white
            self.priceLabel.textColor = UIColor.white
        } else {
            self.paymentLabel.textColor = UIColor.appBlueColor()
            self.priceLabel.textColor = UIColor.appBlueColor()
        }
        
        self.paymentLabel.text = "\(orderPaymentInfo.status.rawValue.uppercased())" + " " + "\(Int(orderPaymentInfo.percentage))%"
        
        let priceString = String(format: "%.2f", orderPaymentInfo.price)
        self.priceLabel.text =  "£ " + priceString

        self.showSeparator(show: showSeparator)
    }

}
