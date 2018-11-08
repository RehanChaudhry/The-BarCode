//
//  ShareOfferCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ShareOfferCell: UITableViewCell, NibReusable {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setUpCell(contact: Contact) {
        
        if contact.fullName.count == 0 {
            self.textLabel?.text = contact.email
            self.detailTextLabel?.text = ""
        } else {
            self.textLabel?.text = contact.fullName
            self.detailTextLabel?.text = contact.email
        }
        
        self.detailTextLabel?.textColor = UIColor.appLightGrayColor()
        
        if contact.isSelected {
            self.accessoryType = .checkmark
            self.textLabel?.textColor = UIColor.appBlueColor()
        } else {
            self.accessoryType = .none
            self.textLabel?.textColor = UIColor.white
        }
    }
    
}
