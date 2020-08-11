//
//  BarContactTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 11/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol BarContactTableViewCellDelegate: class {
    func barContactTableViewCell(cell: BarContactTableViewCell, websiteButtonTapped sender: UIButton)
    func barContactTableViewCell(cell: BarContactTableViewCell, callButtonTapped sender: UIButton)
    func barContactTableViewCell(cell: BarContactTableViewCell, emailButtonTapped sender: UIButton)
    func barContactTableViewCell(cell: BarContactTableViewCell, directionButtonTapped sender: UIButton)
}

class BarContactTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var websitePlaceholderLabel: UILabel!
    @IBOutlet var phoneNumberPlaceholderLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneNumberButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    @IBOutlet var websiteLabelHeight: NSLayoutConstraint!
    @IBOutlet var phoneNumberLabelHeight: NSLayoutConstraint!
    
    weak var delegate: BarContactTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(bar: Bar) {
        
        self.addressLabel.text = bar.address.value
        self.emailButton.setTitle(bar.contactEmail.value, for: .normal)
        
        if bar.website.value == "" {
            self.websiteButton.isHidden = true
            self.websitePlaceholderLabel.isHidden = true
            self.websiteLabelHeight.constant = 0.0
            self.websiteButton.setTitle("", for: .normal)
        } else {
            self.websiteButton.isHidden = false
            self.websitePlaceholderLabel.isHidden = false
            self.websiteLabelHeight.constant = 40.0
            self.websiteButton.setTitle(bar.website.value, for: .normal)
        }
        
        if bar.contactNumber.value == "" {
            self.phoneNumberButton.isHidden = true
            self.phoneNumberPlaceholderLabel.isHidden = true
            self.phoneNumberLabelHeight.constant = 0.0
            self.phoneNumberButton.setTitle("", for: .normal)
        } else {
            self.phoneNumberButton.isHidden = false
            self.phoneNumberPlaceholderLabel.isHidden = false
            self.phoneNumberLabelHeight.constant = 40.0
            self.phoneNumberButton.setTitle(bar.contactNumber.value, for: .normal)
        }
    }
    
    //MARK: My IBActions
    @IBAction func websiteButtonTapped(sender: UIButton) {
        self.delegate?.barContactTableViewCell(cell: self, websiteButtonTapped: sender)
    }
    
    @IBAction func callButtonTapped(sender: UIButton) {
        self.delegate?.barContactTableViewCell(cell: self, callButtonTapped: sender)
    }
    
    @IBAction func emailButtonTapped(sender: UIButton) {
        self.delegate?.barContactTableViewCell(cell: self, emailButtonTapped: sender)
    }
    
    @IBAction func directionsButtonTapped(sender: UIButton) {
        self.delegate?.barContactTableViewCell(cell: self, directionButtonTapped: sender)
    }
}
