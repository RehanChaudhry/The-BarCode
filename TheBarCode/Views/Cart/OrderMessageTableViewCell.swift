//
//  OrderMessageTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 14/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import MLLabel

class OrderMessageTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var infoLabel: MLLinkLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.infoLabel.dataDetectorTypes = .attributedLink
        
        self.infoLabel.linkTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setUpCell(messageInfo: OrderMessage) {
        self.infoLabel.attributedText = messageInfo.message
        
        self.showSeparator(show: false)
    }
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
}
