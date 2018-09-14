//
//  MenuCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 29/03/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class MenuCell: UITableViewCell, NibReusable {

    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var titleLabelLeftMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(menuItem: MenuItem) {
        
        let menuDesc = menuItem.type.description()
        
        if menuDesc.icon == nil {
            titleLabelLeftMargin.constant = -30.0
        } else {
            titleLabelLeftMargin.constant = 24.0
        }
        
        titleLabel.text = menuDesc.title
        titleLabel.font = UIFont.appRegularFontOf(size: CGFloat(menuDesc.fontSize))
        
        if let imageName = menuDesc.icon {
            iconImageView.image = UIImage(named: imageName)
        } else {
            iconImageView.image = nil
        }

        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        
        if menuDesc.showSeparator {
            separatorInset = UIEdgeInsetsMake(0.0, titleLabel.frame.origin.x, 0.0, 0.0)
        } else {
            separatorInset = UIEdgeInsetsMake(0.0, 20000, 0.0, 0.0)
        }
    }
    
}
