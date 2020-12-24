//
//  ProductModifierHeader.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/12/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ProductModifierHeader: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var subtitleContainer: UIView!
    
    @IBOutlet var subtitleLabel: UILabel!
    
    //MARK: My Methods
    func setUpHeader(group: ProductModifierGroup) {
        
        let titleAttributes = [NSAttributedStringKey.font : UIFont.appBoldFontOf(size: 20.0),
                               NSAttributedStringKey.foregroundColor : UIColor.white]
        
        let detailAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedStringKey.foregroundColor : UIColor.white]
        
        
        let attributedTitle = NSAttributedString(string: group.name, attributes: titleAttributes)
        let attributedDetail = NSAttributedString(string: "\nChoose upto \(group.max)", attributes: detailAttributes)
        
        let attributedString = NSMutableAttributedString()
        attributedString.append(attributedTitle)
        
        if group.max > 1 {
            attributedString.append(attributedDetail)
        }
        
        self.titleLabel.attributedText = attributedString
        
        self.subtitleContainer.isHidden = !group.isRequired
    }
}
