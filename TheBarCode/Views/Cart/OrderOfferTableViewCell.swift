//
//  OrderOfferTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 03/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderOfferTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionView.layer.cornerRadius = 8
        self.selectionView.layer.borderWidth = 2
        self.selectionView.layer.borderColor = UIColor.appCartUnSelectedColor().cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
    
    func setupCell(orderOfferInfo: OrderOfferInfo, showSeparator: Bool) {
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(orderOfferInfo.text, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.selectionView.backgroundColor = orderOfferInfo.isSelected ? UIColor.appBlueColor() : UIColor.appCartUnSelectedColor()
        
        self.showSeparator(show: showSeparator)
        
        if showSeparator {
            self.bottomMargin.constant = 24.0
        } else {
            self.bottomMargin.constant = 8.0
        }
    }
    
}
