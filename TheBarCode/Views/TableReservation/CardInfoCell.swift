//
//  CardInfoCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 30/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class CardInfoCell: UITableViewCell, NibReusable {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var selectionImageView: UIImageView!
    
    @IBOutlet var cardButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        self.selectionImageView.image = self.selectionImageView.image?.withRenderingMode(.alwaysTemplate)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func maskCorners(radius: CGFloat, mask: CACornerMask) {
        if #available(iOS 11.0, *) {
            self.containerView.layer.cornerRadius = radius
            self.containerView.layer.maskedCorners = mask
        }
    }
    
    func setUpCell() {
        let boldAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                              NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
        let regularAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appGrayColor(),
                                 NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
        
        let cardType = NSMutableAttributedString(string: "VISA ", attributes: boldAttributes)
        let placeholder = NSMutableAttributedString(string: "Ending In ", attributes: regularAttributes)
        let cardNo = NSMutableAttributedString(string: "1890", attributes: boldAttributes)
        
        let attributesInfo = NSMutableAttributedString()
        attributesInfo.append(cardType)
        attributesInfo.append(placeholder)
        attributesInfo.append(cardNo)
        
        UIView.performWithoutAnimation {
            self.cardButton.setAttributedTitle(attributesInfo, for: .normal)
            self.cardButton.layoutIfNeeded()
        }
    }
    
    //MARK: My IBActions
    @IBAction func cardButtonTapped(sender: UIButton) {
        
    }
    
    
}
