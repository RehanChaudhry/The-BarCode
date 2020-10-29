//
//  OrderDeliveryAddressTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 06/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderDeliveryAddressTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var conditionLabel: UILabel!
    
    @IBOutlet var conditionLabelTop: NSLayoutConstraint!
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
        self.showSeparator(show: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
    
    func setupCell(address: OrderDeliveryAddress) {
        
        if address.isLoading {
            self.activityIndicatorView.startAnimating()
            
            self.titleLabel.text = ""
            self.subTitleLabel.text = ""
            self.infoLabel.text = ""
            
        } else if let deliveryAddress = address.address {
            self.activityIndicatorView.stopAnimating()
            
            self.titleLabel.text = "Delivery Details: " + deliveryAddress.label
            
            let attributedSubtitle = NSMutableAttributedString()
            
            let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.white]
            let attributedAddress = NSAttributedString(string: deliveryAddress.address, attributes: normalAttributes)
            
            attributedSubtitle.append(attributedAddress)
            
            let italicAttributes = [NSAttributedString.Key.font : UIFont.appItalicFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.white]
            let attributedCity = NSAttributedString(string: "\n" + deliveryAddress.city, attributes: italicAttributes)
            
            attributedSubtitle.append(attributedCity)
            
            if deliveryAddress.additionalInfo.count > 0 {
                let infottributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                        NSAttributedString.Key.foregroundColor : UIColor.appGrayColor()]
                let attribtuedInfo = NSAttributedString(string: "\n" + deliveryAddress.additionalInfo, attributes: infottributes)
                attributedSubtitle.append(attribtuedInfo)
            }
            
            self.subTitleLabel.attributedText = attributedSubtitle
            self.infoLabel.text = ""
            
        } else {
            self.activityIndicatorView.stopAnimating()
            
            self.titleLabel.text = ""
            self.subTitleLabel.text = ""
            self.infoLabel.text = "Please select delivery address"
        }
        
        if let deliveryCondition = address.deliveryCondition, deliveryCondition.count > 0 {
            self.conditionLabel.text = deliveryCondition
            self.conditionLabelTop.constant = 8.0
        } else {
            self.conditionLabel.text = ""
            self.conditionLabelTop.constant = 0.0
        }
        
        self.conditionLabel.textColor = UIColor.appBlueColor()
    }
    
}
