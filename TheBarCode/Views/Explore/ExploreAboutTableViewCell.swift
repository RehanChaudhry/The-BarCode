//
//  ExploreAboutTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class ExploreAboutTableViewCell: UITableViewCell {

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var timingsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneNumberButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
