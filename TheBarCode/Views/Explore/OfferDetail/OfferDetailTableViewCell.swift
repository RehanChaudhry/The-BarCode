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
import DTCoreText

protocol OfferDetailTableViewCellDelegate: class {
    func OfferDetailCell(cell: OfferDetailTableViewCell, viewDirectionButtonTapped sender: UIButton)
}

class OfferDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var detailLabel: DTAttributedLabel!
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
    
    func configCell(deal: Deal) {
    
        let attributedString = NSMutableAttributedString(attributedString: deal.detail.value.html2Attributed(isTitle: false) ?? NSMutableAttributedString(string: ""))
        let range = NSRange(location: 0, length: attributedString.length)        
        
        let enumerationOption = NSAttributedString.EnumerationOptions(rawValue: 0)
        
        attributedString.enumerateAttribute(NSAttributedStringKey(DTBackgroundColorAttribute), in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey(DTBackgroundColorAttribute), range: range)
            attributedString.addAttributes([NSAttributedStringKey(DTBackgroundColorAttribute) : UIColor.clear.cgColor], range: range)
        }
        
        attributedString.enumerateAttribute(NSAttributedStringKey(String(kCTForegroundColorAttributeName)), in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey(String(kCTForegroundColorAttributeName)), range: range)
                attributedString.addAttributes([NSAttributedStringKey(String(kCTForegroundColorAttributeName)) : UIColor.white.cgColor], range: range)
        }
        
        attributedString.enumerateAttribute(NSAttributedStringKey.link, in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()], range: range)
        }
        
        self.detailLabel.attributedString = attributedString
        self.detailLabel.delegate = self
        
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

        let validtyPlaceHodler = ""
        
        if !deal.shouldShowDate.value {
            self.validityLabel.text = ""
        } else {
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
                
                if fromDate != toDate {
                    finalAttributedText.append(attributedTo)
                    finalAttributedText.append(attributedToDate)
                }
                
                if deal.hasTime.value {
                    finalAttributedText.append(attributedFrom)
                    finalAttributedText.append(attributedFromTime)
                    finalAttributedText.append(attributedTo)
                    finalAttributedText.append(attributedToTime)
                }
                
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
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate.OfferDetailCell(cell: self, viewDirectionButtonTapped: sender)
    }
}

//MARK: DTAttributedTextContentViewDelegate
extension OfferDetailTableViewCell: DTAttributedTextContentViewDelegate {
    
    func attributedTextContentView(_ attributedTextContentView: DTAttributedTextContentView!, viewForLink url: URL!, identifier: String!, frame: CGRect) -> UIView! {
        let button = DTLinkButton(frame: frame)
        button.addTarget(self, action: #selector(dtLinkButtonTapped(sender:)), for: .touchUpInside)
        button.url = url
        button.minimumHitSize = CGSize(width: 25.0, height: 25.0)
        button.guid = identifier
        return button
    }
    
    @objc func dtLinkButtonTapped(sender: DTLinkButton) {
        UIApplication.shared.open(sender.url, options: [:], completionHandler: nil)
    }
}
