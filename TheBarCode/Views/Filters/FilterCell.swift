//
//  StandardOfferTypeCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FilterCell: UITableViewCell, NibReusable {

    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(offer: StandardOffer) {
      
        self.titleLabel.text = offer.discountValue.value + "% Discount"
        self.iconImageView.image = Utility.shared.getPinImage(offerType: offer.type)
        
        if offer.isSelected.value {
            self.accessoryType = .checkmark
            self.tintColor = UIColor.appBlueColor()
        } else {
            self.accessoryType = .none
        }
    }
    
    
}
