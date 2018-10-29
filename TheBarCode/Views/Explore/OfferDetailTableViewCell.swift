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
            self.distanceLabel.text = Utility.shared.getformattedDistance(distance: distance)
        } else {
            self.distanceLabel.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm:a"
        
        let validtyPlaceHodler = "Validity period: "
        let fromDate = dateFormatter.string(from: deal.startDate)
        let toDate = dateFormatter.string(from: deal.endDate)
        let to = " to "
        let from = " from "
        
        let fromTime = timeFormatter.string(from: deal.startTime)
        let toTime = timeFormatter.string(from: deal.endTime)
        
        let blueAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                               NSAttributedStringKey.foregroundColor : UIColor.white]
        
        let attributedTo = NSAttributedString(string: to, attributes: whiteAttributes)
        let attributedFrom = NSAttributedString(string: from, attributes: whiteAttributes)
        
        let attributedPlaceholder = NSAttributedString(string: validtyPlaceHodler, attributes: whiteAttributes)
        let attributedFromDate = NSAttributedString(string: fromDate, attributes: blueAttributes)
        let attributedToDate = NSAttributedString(string: toDate, attributes: blueAttributes)
        
        let attributedFromTime = NSAttributedString(string: fromTime, attributes: blueAttributes)
        let attributedToTime = NSAttributedString(string: toTime, attributes: blueAttributes)
        
        let finalAttributedText = NSMutableAttributedString()
        finalAttributedText.append(attributedPlaceholder)
        finalAttributedText.append(attributedFromDate)
        finalAttributedText.append(attributedTo)
        finalAttributedText.append(attributedToDate)
        finalAttributedText.append(attributedFrom)
        finalAttributedText.append(attributedFromTime)
        finalAttributedText.append(attributedTo)
        finalAttributedText.append(attributedToTime)
        
        /*
        let blueAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let finalText = validtyPlaceHodler + fromDate + to + toDate + from + fromTime + to + toTime
        let attributedText = NSMutableAttributedString(string: finalText)
        attributedText.addAttributes(whiteAttributes, range: (finalText as NSString).range(of: validtyPlaceHodler))
        attributedText.addAttributes(blueAttributes, range: (finalText as NSString).range(of: fromDate))
        attributedText.addAttributes(whiteAttributes, range: (finalText as NSString).range(of: to))
        attributedText.addAttributes(blueAttributes, range: (finalText as NSString).range(of: toDate))
        attributedText.addAttributes(whiteAttributes, range: (finalText as NSString).range(of: from))
        attributedText.addAttributes(blueAttributes, range: (finalText as NSString).range(of: fromTime))
        attributedText.addAttributes(whiteAttributes, range: (finalText as NSString).range(of: to))
        
        
        
        let validtyPlaceHodler = "Validity period: "
        let to = " to "
        let fromDate = Date.getFormattedDate(string: deal.starDateTime.value, formatter: "MMM dd  hh:mm a")
        let toDate = Date.getFormattedDate(string: deal.endDateTime.value, formatter: "MMM dd  hh:mm a")
        
        let finalText = validtyPlaceHodler + fromDate + to + toDate
        
        let attributedText = NSMutableAttributedString(string: finalText, attributes: [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0)])
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: validtyPlaceHodler))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: (finalText as NSString).range(of: to))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: fromDate))
        attributedText.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.appBlueColor(), range: (finalText as NSString).range(of: toDate))
        */
        
        
        self.validityLabel.attributedText = finalAttributedText
    }
    
}
