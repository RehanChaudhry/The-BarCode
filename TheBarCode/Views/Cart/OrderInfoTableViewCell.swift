//
//  OrderInfoTableViewCell.swift
//  TheBarCode
//
//  Created by Macbook on 21/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderInfoTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(orderItem: OrderItem) {
        self.detailsLabel.text = "\(orderItem.quantity) x " + orderItem.name
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.priceLabel.text = "£ " + totalPriceString
    }
    
    func setupCell(orderDiscountInfo: OrderDiscountInfo) {
        self.detailsLabel.text =  orderDiscountInfo.title
        
        let totalPriceString = String(format: "%.2f", orderDiscountInfo.price)
        self.priceLabel.text = "£ " + totalPriceString
    }
    
    func setupCell(orderDeliveryInfo: OrderDeliveryInfo) {
          self.detailsLabel.text =  orderDeliveryInfo.title
          
          let totalPriceString = String(format: "%.2f", orderDeliveryInfo.price)
          self.priceLabel.text = "£ " + totalPriceString
      }
    
    func setupCell(orderTotalBillInfo: OrderTotalBillInfo) {
          self.detailsLabel.text =  orderTotalBillInfo.title
          
          let totalPriceString = String(format: "%.2f", orderTotalBillInfo.price)
          self.priceLabel.text = "£ " + totalPriceString
      }

}
