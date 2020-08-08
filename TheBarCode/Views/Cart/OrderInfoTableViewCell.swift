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
    
    //MARK: My Methods
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
            self.mainView.layer.cornerRadius = radius
            self.mainView.layer.maskedCorners = mask
        }
    }
    
    func setupMainViewAppearanceAsBlack() {
        self.mainView.backgroundColor = UIColor.black
        self.leftLabel.textColor = UIColor.appBlueColor()
        self.rightLabel.textColor = UIColor.appBlueColor()
    }
    
    func setupMainViewAppearanceAsStandard() {
        self.mainView.backgroundColor = UIColor.appBgSecondaryGrayColor()
        self.leftLabel.textColor = UIColor.white
        self.rightLabel.textColor = UIColor.white
    }

    func setupCell(barInfo: BarInfo, showSeparator: Bool) {
        self.leftLabel.text = barInfo.barName
        self.leftLabel.font = UIFont.appBoldFontOf(size: 14)

        self.rightLabel.isHidden = true
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 8.0, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        
        self.setupMainViewAppearanceAsStandard()
    }
    
    func setupCell(orderItem: OrderItem, showSeparator: Bool) {
        self.leftLabel.text = "\(orderItem.quantity) x " + orderItem.name
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
        
        self.setupMainViewAppearanceAsStandard()
    }
    
    func setupCell(orderDiscountInfo: OrderDiscountInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderDiscountInfo.title
        
        if orderDiscountInfo.price > 0.0 {
            let totalPriceString = String(format: "%.2f", orderDiscountInfo.price)
            self.rightLabel.text = "- £ " + totalPriceString
        } else {
            self.rightLabel.text = ""
        }
        
        self.rightLabel.isHidden = false
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
        
        self.setupMainViewAppearanceAsStandard()
    }
    
    func setupCell(orderDeliveryInfo: OrderDeliveryInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderDeliveryInfo.title
                
        let totalPriceString = String(format: "%.2f", orderDeliveryInfo.price)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
              
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
        
        self.setupMainViewAppearanceAsStandard()
    }
    
    func setupCell(orderTotalBillInfo: OrderTotalBillInfo, showSeparator: Bool) {
        self.leftLabel.text =  orderTotalBillInfo.title
        
        let totalPriceString = String(format: "%.2f", orderTotalBillInfo.price)
        self.rightLabel.text = "£ " + totalPriceString
        self.rightLabel.isHidden = false
        
        self.rightLabel.font = UIFont.appBoldFontOf(size: 14)
        self.mainView.backgroundColor = UIColor.black
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 8.0, mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        
        self.setupMainViewAppearanceAsBlack()
      }

    func setupCell(reservationInfo: ReservationInfo, showSeparator: Bool) {
        
        self.setupMainViewAppearanceAsStandard()
        
        if reservationInfo.type == .card {
            
            let components = reservationInfo.value.components(separatedBy: "-->")
            
            let boldAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                  NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
            let regularAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appGrayColor(),
                                     NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
            
            let cardType = NSMutableAttributedString(string: components.first ?? "", attributes: boldAttributes)
            let placeholder = NSMutableAttributedString(string: " Ending In ", attributes: regularAttributes)
            let cardNo = NSMutableAttributedString(string: components.last ?? "", attributes: boldAttributes)
            
            let attributesInfo = NSMutableAttributedString()
            attributesInfo.append(cardType)
            attributesInfo.append(placeholder)
            attributesInfo.append(cardNo)
            
            self.rightLabel.attributedText = attributesInfo
        } else {
            self.rightLabel.text =  reservationInfo.value
        }
        
        self.leftLabel.text =  reservationInfo.title
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
    }
    
    func setupCell(reservationInfo: ReservationInfo, status: ReservationStatus, showSeparator: Bool) {
        self.leftLabel.text =  reservationInfo.title
        
        self.rightLabel.text =  reservationInfo.value.capitalized
        
        self.rightLabel.isHidden = false
        self.rightLabel.font = UIFont.appBoldFontOf(size: 14)
        
        self.showSeparator(show: showSeparator)
        
        self.maskCorners(radius: 0.0, mask: [])
        
        self.setupMainViewAppearanceAsBlack()
    }

}
