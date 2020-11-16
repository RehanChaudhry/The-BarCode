//
//  CardInfoCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 30/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CardInfoCellDelegate: class {
    func cardInfoCell(cell: CardInfoCell, cardButtonTapped sender: UIButton)
    func cardInfoCell(cell: CardInfoCell, deleteButtonTapped sender: UIButton)
}

class CardInfoCell: UITableViewCell, NibReusable {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var selectionImageView: UIImageView!
    
    @IBOutlet var cardButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: CardInfoCellDelegate?
    
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
    
    func setUpCell(card: CreditCard, isSelected: Bool, canShowSelection: Bool) {
        
        let boldAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                              NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 13.0)]
        let regularAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appGrayColor(),
                                 NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 13.0)]
                
        let cardType = NSMutableAttributedString(string: "\(CreditCardType.displayableType(raw: card.typeRaw).capitalized) ", attributes: boldAttributes)
        let placeholder = NSMutableAttributedString(string: "Ending In ", attributes: regularAttributes)
        let cardNo = NSMutableAttributedString(string: card.endingIn.count > 4 ? String(card.endingIn.suffix(4)) : card.endingIn, attributes: boldAttributes)
        
        let attributesInfo = NSMutableAttributedString()
        attributesInfo.append(cardType)
        attributesInfo.append(placeholder)
        attributesInfo.append(cardNo)
        
        UIView.performWithoutAnimation {
            self.cardButton.setAttributedTitle(attributesInfo, for: .normal)
            self.cardButton.layoutIfNeeded()
        }
        
        self.selectionImageView.isHidden = !(isSelected && canShowSelection)
        self.iconImageView.image = CreditCardType.iconImage(raw: card.typeRaw)
        
        if card.isDeleting {
            self.activityIndicator.startAnimating()
            self.deleteButton.isHidden = true
        } else {
            self.activityIndicator.stopAnimating()
            self.deleteButton.isHidden = false
        }
    }
    
    //MARK: My IBActions
    @IBAction func cardButtonTapped(sender: UIButton) {
        self.delegate?.cardInfoCell(cell: self, cardButtonTapped: sender)
    }
    
    @IBAction func deleteButtonTapped(sender: UIButton) {
        self.delegate?.cardInfoCell(cell: self, deleteButtonTapped: sender)
    }
}
