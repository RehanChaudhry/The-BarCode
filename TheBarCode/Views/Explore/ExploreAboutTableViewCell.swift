//
//  ExploreAboutTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ExploreAboutTableViewCellDelegate: class {
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, websiteButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, directionsButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, callButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, emailButtonTapped sender: UIButton)
}

class ExploreAboutTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var websitePlaceholderLabel: UILabel!
    
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
    
    @IBOutlet var websitePlaceholderLabelHeight: NSLayoutConstraint!
    @IBOutlet var phonePlaceholderLabelTop: NSLayoutConstraint!
    @IBOutlet var phoneNumberLabelTop: NSLayoutConstraint!
    
    @IBOutlet var websiteButtonHeight: NSLayoutConstraint!
    @IBOutlet var phoneNumberButtonHeight: NSLayoutConstraint!
    @IBOutlet var emailButtonHeight: NSLayoutConstraint!

    weak var delegate: ExploreAboutTableViewCellDelegate!
    
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
        phoneNumberButton.setTitle(explore.contactNumber.value, for: .normal)
        addressLabel.text = explore.address.value
        emailButton.setTitle(explore.contactEmail.value, for: .normal)
        
        if explore.website.value == "" {
//            self.websitePlaceholderLabel.isHidden = true
//            self.websiteButton.isHidden = true
            self.websiteButton.setTitle("N/A", for: .normal)
            self.websiteButton.isUserInteractionEnabled = false
            
//            self.websiteButtonHeight.constant = 0.0
//            self.phonePlaceholderLabelTop.constant = 0.0
//            self.phoneNumberLabelTop.constant = 0.0
            
        } else {
//            self.websitePlaceholderLabel.isHidden = false
//            self.websiteButton.isHidden = false
            self.websiteButton.setTitle(explore.website.value, for: .normal)
            self.websiteButton.isUserInteractionEnabled = true
            
//            self.websiteButtonHeight.constant = 17.0
//            self.phonePlaceholderLabelTop.constant = 15.0
//            self.phoneNumberLabelTop.constant = 15.0
        }
    }
    
    //MARK: My IBActions
    @IBAction func websiteButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, websiteButtonTapped: sender)
    }
    
    @IBAction func callButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, callButtonTapped: sender)
    }
    
    @IBAction func emailButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, emailButtonTapped: sender)
    }
    
    @IBAction func directionsButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, directionsButtonTapped: sender)
    }
}
