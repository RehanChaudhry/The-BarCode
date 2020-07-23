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
    
    @IBOutlet var mainView: UIView!
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
    
    func setupCell(barInfo: BarInfo) {
        self.detailsLabel.text = barInfo.barName
        self.detailsLabel.font = UIFont.appBoldFontOf(size: 14)

        self.priceLabel.isHidden = true
    }
    
    func setupCell(orderItem: OrderItem) {
        self.detailsLabel.text = "\(orderItem.quantity) x " + orderItem.name
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.priceLabel.text = "£ " + totalPriceString
        self.priceLabel.isHidden = false
    }
    
    func setupCell(orderDiscountInfo: OrderDiscountInfo) {
        self.detailsLabel.text =  orderDiscountInfo.title
        
        let totalPriceString = String(format: "%.2f", orderDiscountInfo.price)
        self.priceLabel.text = "£ " + totalPriceString
        self.priceLabel.isHidden = false
    }
    
    func setupCell(orderDeliveryInfo: OrderDeliveryInfo) {
          self.detailsLabel.text =  orderDeliveryInfo.title
          
          let totalPriceString = String(format: "%.2f", orderDeliveryInfo.price)
          self.priceLabel.text = "£ " + totalPriceString
          self.priceLabel.isHidden = false
      }
    
    func setupCell(orderTotalBillInfo: OrderTotalBillInfo) {
        self.detailsLabel.text =  orderTotalBillInfo.title
        self.detailsLabel.textColor  = UIColor.appBlueColor()

        let totalPriceString = String(format: "%.2f", orderTotalBillInfo.price)
        self.priceLabel.text = "£ " + totalPriceString
        self.priceLabel.isHidden = false
        self.priceLabel.textColor  = UIColor.appBlueColor()
        self.priceLabel.font = UIFont.appBoldFontOf(size: 14)
        self.mainView.backgroundColor = UIColor.black
        
      }

    func setupCell(reservationInfo: ReservationInfo) {
        self.detailsLabel.text =  reservationInfo.title
        self.priceLabel.text =  reservationInfo.value

    }
}
