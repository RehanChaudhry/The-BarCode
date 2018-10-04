//
//  ContactTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ContactTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
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
        self.titleLabel.text = contact.fullName
        
        if contact.isSelected {
            self.accessoryType = .checkmark
            self.titleLabel.textColor = UIColor.appBlueColor()
        } else {
            self.accessoryType = .none
            self.titleLabel.textColor = UIColor.white
        }
    }
    
}
