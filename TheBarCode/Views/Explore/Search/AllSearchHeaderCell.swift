//
//  AllSearchHeaderCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class AllSearchHeaderCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(title: String, strokeColor: UIColor?) {
        self.titleLabel.text = title.uppercased()
        
        if let strokeColor = strokeColor {
            self.titleLabel.textColor = strokeColor
        } else {
            self.titleLabel.textColor = UIColor.white
        }
    }
}
