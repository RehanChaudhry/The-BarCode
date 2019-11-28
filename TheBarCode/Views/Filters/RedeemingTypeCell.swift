//
//  RedeemingTypeCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class RedeemingTypeCell: UITableViewCell, NibReusable {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var stateImageView: UIImageView!
    
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
    
    //MARK: My Methods
    func setupCell(redeemingType: RedeemingTypeModel) {
        self.titleLabel.text = redeemingType.type.title()
        self.iconImageView.image = redeemingType.type.icon()
        
        if redeemingType.selected {
            self.stateImageView.image = UIImage(named: "icon_radio_selected")
        } else {
            self.stateImageView.image = UIImage(named: "icon_radio_unselected")
        }
    }
}
