//
//  OfferDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OfferDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet var validityLabel: UILabel!
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.selectionStyle = .none
        
        let validtyPlaceHodler = "Validity period: "
        let to = " to "
        let fromDate = "June 10 10:00 am"
        let toDate = "June 12 12:00 pm"
        
        let finalText = validtyPlaceHodler + fromDate + to + toDate
        
        let attributedText = NSMutableAttributedString(string: finalText, attributes: [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0)])
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: validtyPlaceHodler))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: to))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: fromDate))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: toDate))
        
        self.validityLabel.attributedText = attributedText
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(deal: Deal){
        
        self.detailLabel.text = deal.detail.value
        self.barNameLabel.text = deal.establishment.value?.title.value
        
        if let distance = deal.establishment.value?.distance.value {
            self.distanceLabel.text = distance
        } else {
            self.distanceLabel.isHidden = true
        }
        
        let validtyPlaceHodler = "Validity period: "
        let to = " to "
        let fromDate = deal.startTime.value
        let toDate = deal.endTime.value
        
        let finalText = validtyPlaceHodler + fromDate + to + toDate
        
        let attributedText = NSMutableAttributedString(string: finalText, attributes: [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0)])
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: validtyPlaceHodler))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: to))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: fromDate))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: toDate))
        
        self.validityLabel.attributedText = attributedText
    }
    
}
