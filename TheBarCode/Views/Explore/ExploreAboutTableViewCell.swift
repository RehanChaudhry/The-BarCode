//
//  ExploreAboutTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ExploreAboutTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var timingsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneNumberButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    @IBOutlet var websiteButtonHeight: NSLayoutConstraint!
    @IBOutlet var phoneNumberButtonHeight: NSLayoutConstraint!
    @IBOutlet var emailButtonHeight: NSLayoutConstraint!

    override func layoutSubviews() {
        super.layoutSubviews()

        self.websiteButtonHeight.constant = self.websiteLabel.frame.height
        self.phoneNumberButtonHeight.constant = self.phoneNumberLabel.frame.height
        self.emailButtonHeight.constant = self.emailLabel.frame.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
                
        self.emailLabel.isHidden = true
        self.websiteLabel.isHidden = true
        self.phoneNumberLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK: My Methods
    
    func setUpCell(explore: Explore) {
        infoLabel.text = explore.detail.value
        timingsLabel.text = explore.businessTiming.value
        websiteButton.setTitle(explore.website.value, for: .normal)
        phoneNumberButton.setTitle(explore.contactNumber.value, for: .normal)
        addressLabel.text = explore.address.value
        emailButton.setTitle(explore.contactEmail.value, for: .normal)
        
    }
}
