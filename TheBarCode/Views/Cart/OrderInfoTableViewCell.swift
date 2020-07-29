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
    
    @IBOutlet var leftLabel: UILabel!
    @IBOutlet var rightLabel: UILabel!
    
    @IBOutlet var topMargin: NSLayoutConstraint!
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func adjustMargins(adjustTop: Bool, adjustBottom: Bool) {
        self.topMargin.constant = adjustTop ? 16.0 : 8.0
        self.bottomMargin.constant = adjustBottom ? 16.0 : 8.0
    }
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
    
    func maskCorners(radius: CGFloat, mask: CACornerMask) {
        if #available(iOS 11.0, *) {
            self.mainView.layer.cornerRadius = 8.0
            self.mainView.layer.maskedCorners = mask
        }
    }

    func setupCell(barInfo: BarInfo, showSeparator: Bool) {
        self.leftLabel.text = barInfo.barName
        self.leftLabel.font = UIFont.appBoldFontOf(size: 14)

        self.rightLabel.isHidden = true
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 8.0, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    }
    
    func setupCell(orderItem: OrderItem, showSeparator: Bool) {
        self.leftLabel.text = "\(orderItem.quantity) x " + orderItem.name
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }
    
    func setupCell(orderDiscountInfo: OrderDiscountInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderDiscountInfo.title
        
        let totalPriceString = String(format: "%.2f", orderDiscountInfo.price)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }
    
    func setupCell(orderDeliveryInfo: OrderDeliveryInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderDeliveryInfo.title
                
        let totalPriceString = String(format: "%.2f", orderDeliveryInfo.price)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
              
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }
    
    func setupCell(orderTotalBillInfo: OrderTotalBillInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderTotalBillInfo.title
        self.leftLabel.textColor  = UIColor.appBlueColor()

        let totalPriceString = String(format: "%.2f", orderTotalBillInfo.price)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
        self.rightLabel.textColor  = UIColor.appBlueColor()
        self.rightLabel.font = UIFont.appBoldFontOf(size: 14)
        self.mainView.backgroundColor = UIColor.black
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 8.0, mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
      }

    func setupCell(reservationInfo: ReservationInfo, showSeparator: Bool) {
        self.leftLabel.text =  reservationInfo.title
        self.rightLabel.text =  reservationInfo.value
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }
    
    func setupCell(reservationInfo: ReservationInfo, status: ReservationStatus, showSeparator: Bool) {
        self.leftLabel.text =  reservationInfo.title
        self.leftLabel.textColor  = UIColor.appBlueColor()


        self.rightLabel.text =  reservationInfo.value.capitalized
        
        self.rightLabel.isHidden = false
        self.rightLabel.textColor  = UIColor.appBlueColor()
        self.rightLabel.font = UIFont.appBoldFontOf(size: 14)
        self.mainView.backgroundColor = UIColor.black
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }

}
