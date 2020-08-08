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
        
        self.titleLabel.text = "Delivery Details: " + address.label
        
        let attributedSubtitle = NSMutableAttributedString()
        
        let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedAddress = NSAttributedString(string: address.address, attributes: normalAttributes)
        
        attributedSubtitle.append(attributedAddress)
        
        let italicAttributes = [NSAttributedString.Key.font : UIFont.appItalicFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedCity = NSAttributedString(string: "\n" + address.city, attributes: italicAttributes)
        
        attributedSubtitle.append(attributedCity)
        
        if address.note.count > 0 {
            let infottributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.appGrayColor()]
            let attribtuedInfo = NSAttributedString(string: "\n" + address.note, attributes: infottributes)
            attributedSubtitle.append(attribtuedInfo)
        }
        
        self.subTitleLabel.attributedText = attributedSubtitle
    }
    
}
