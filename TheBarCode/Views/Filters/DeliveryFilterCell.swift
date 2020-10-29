//
//  DeliveryFilterCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/10/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class DeliveryFilterCell: UITableViewCell, NibReusable {

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
    
    func setUpCell(delivery: DeliveryFilter) {
      
        self.titleLabel.text = delivery.title
        self.iconImageView.image = UIImage(named: delivery.icon)
        
        if delivery.isSelected {
            self.accessoryType = .checkmark
            self.tintColor = UIColor.appBlueColor()
        } else {
            self.accessoryType = .none
        }
    }
}
