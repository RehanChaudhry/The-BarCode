//
//  OrderOfferDiscountTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 04/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderOfferDiscountTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var topMargin: NSLayoutConstraint!
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    @IBOutlet var labelTopMargin: NSLayoutConstraint!
    @IBOutlet var labelBottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setUpCell(discountInfo: OrderOfferDiscountInfo, isFirst: Bool, isLast: Bool) {
        self.titleLabel.text = discountInfo.title
        
        if discountInfo.value > 0 {
            self.subTitleLabel.text = String(format: "Saving £ %.2f", discountInfo.value)
        } else {
            self.subTitleLabel.text = ""
        }

        self.showSeparator(show: false)
        
        var topMaskCorners: CACornerMask = []
        var bottomMaskCorners: CACornerMask = []
        
        if isFirst {
            topMaskCorners = [CACornerMask.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            self.topMargin.constant = 12.0
            self.labelTopMargin.constant = 12.0
        } else {
            self.topMargin.constant = 0.0
            self.labelTopMargin.constant = 3.0
        }
        
        if isLast {
            bottomMaskCorners = [CACornerMask.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            self.bottomMargin.constant = 12.0
            self.labelBottomMargin.constant = 12.0
        } else {
            self.bottomMargin.constant = 0.0
            self.labelBottomMargin.constant = 3.0
        }
        
        self.maskCorners(radius: 8.0, mask: [topMaskCorners, bottomMaskCorners])
        
    }
    
    func maskCorners(radius: CGFloat, mask: CACornerMask) {
        if #available(iOS 11.0, *) {
            self.containerView.layer.cornerRadius = radius
            self.containerView.layer.maskedCorners = mask
        }
    }
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
}
