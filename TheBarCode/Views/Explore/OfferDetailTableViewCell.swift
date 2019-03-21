//
//  OfferDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FirebaseAnalytics

protocol OfferDetailTableViewCellDelegate: class {
    func OfferDetailCell(cell: OfferDetailTableViewCell, viewDirectionButtonTapped sender: UIButton)
}

class OfferDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet var validityLabel: UILabel!
    @IBOutlet var barNameButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    weak var delegate : OfferDetailTableViewCellDelegate!

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
        self.barNameButton.setTitle(deal.establishment.value?.title.value, for: .normal)
        
        if let distance = deal.establishment.value?.distance.value {
            self.distanceLabel.text = Utility.shared.getformattedDistance(distance: distance)
        } else {
            self.distanceLabel.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let validtyPlaceHodler = "Validity period: "
        
        if deal.statusText.value.lowercased() == "active".lowercased() {
            
            let fromDate = dateFormatter.string(from: deal.startDateTime)
            let toDate = dateFormatter.string(from: deal.endDateTime)
            let to = " to "
            let from = " from "
            
            let fromTime = timeFormatter.string(from: deal.startDateTime)
            let toTime = timeFormatter.string(from: deal.endDateTime)
            
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
            
            self.validityLabel.attributedText = finalAttributedText
            
        } else if deal.statusText.value.lowercased() == "Expired".lowercased() {
            
            let attributesWhite: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.white]
            
            let attributesRed: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.appRedColor()]
            
            let expiredString = "Expired"
            
            let validityAttributedString = NSAttributedString(string: validtyPlaceHodler, attributes: attributesWhite)
            let expiredAttributedString = NSAttributedString(string: expiredString, attributes: attributesRed)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(validityAttributedString)
            finalAttributedString.append(expiredAttributedString)
            
            self.validityLabel.attributedText = finalAttributedString
            
            
        } else {
            let attributesWhite: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.white]
            
            let attributesRed: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.appRedColor()]
            
            let inActiveString = "In-Active"
            
            let validityAttributedString = NSAttributedString(string: validtyPlaceHodler, attributes: attributesWhite)
            let inActiveAttributedString = NSAttributedString(string: inActiveString, attributes: attributesRed)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(validityAttributedString)
            finalAttributedString.append(inActiveAttributedString)
            
            self.validityLabel.attributedText = finalAttributedString
        }
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate.OfferDetailCell(cell: self, viewDirectionButtonTapped: sender)
    }
}
