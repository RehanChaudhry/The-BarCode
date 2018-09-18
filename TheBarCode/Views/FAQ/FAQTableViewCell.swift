//
//  FAQTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 14/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FAQTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func setUpCell(faq: FAQ) {
        titleLabel.text = faq.text
    }
    
}
