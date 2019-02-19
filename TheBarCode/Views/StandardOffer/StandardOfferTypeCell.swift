//
//  StandardOfferTypeCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class StandardOfferTypeCell: UITableViewCell, NibReusable {

    @IBOutlet var offerImageView: UIImageView!
    
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
    
}
