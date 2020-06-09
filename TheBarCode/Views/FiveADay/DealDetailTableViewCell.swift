//
//  DealDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 08/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FirebaseAnalytics
import DTCoreText

protocol DealDetailTableViewCellDelegate: class {
    func dealDetailCell(cell: DealDetailTableViewCell, viewBarDetailButtonTapped sender: UIButton)
    func dealDetailCell(cell: DealDetailTableViewCell, viewDirectionButtonTapped sender: UIButton)
}

class DealDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: DTAttributedLabel!
    
    @IBOutlet weak var barNameButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var validityLabel: UILabel!
    
    
    weak var delegate : DealDetailTableViewCellDelegate!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(deal: FiveADayDeal) {
        
        self.titleLabel.text = deal.subTitle.value.uppercased()
        self.subTitleLabel.text = deal.title.value
                
        let attributedString = NSMutableAttributedString(attributedString: deal.detail.value.html2Attributed(isTitle: false) ?? NSMutableAttributedString(string: ""))
        let range = NSRange(location: 0, length: attributedString.length)
        
        let enumerationOption = NSAttributedString.EnumerationOptions(rawValue: 0)
        
        attributedString.enumerateAttribute(NSAttributedStringKey(DTBackgroundColorAttribute), in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey(DTBackgroundColorAttribute), range: range)
            attributedString.addAttributes([NSAttributedStringKey(DTBackgroundColorAttribute) : UIColor.clear.cgColor], range: range)
        }
        
        attributedString.enumerateAttribute(NSAttributedStringKey(String(kCTForegroundColorAttributeName)), in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey(String(kCTForegroundColorAttributeName)), range: range)
                attributedString.addAttributes([NSAttributedStringKey(String(kCTForegroundColorAttributeName)) : UIColor.gray.cgColor], range: range)
        }
        
        attributedString.enumerateAttribute(NSAttributedStringKey.link, in: range, options: enumerationOption) { (value, range, stop) in
            attributedString.removeAttribute(NSAttributedStringKey.foregroundColor, range: range)
            attributedString.addAttributes([NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()], range: range)
        }
        
        self.detailLabel.attributedString = attributedString
        self.detailLabel.delegate = self
        
        self.barNameButton.setTitle(deal.establishment.value!.title.value, for: .normal)
       
        if let distance = deal.establishment.value?.distance {
            self.locationLabel.isHidden = false
            self.locationLabel.text = Utility.shared.getformattedDistance(distance: distance.value)
        } else {
            self.locationLabel.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
//        let validtyPlaceHodler = "Validity period: "
        
        let fromDate = dateFormatter.string(from: deal.startDateTime)
        let toDate = dateFormatter.string(from: deal.endDateTime)
//        let to = " to "
//        let from = " from "
        
        let fromTime = timeFormatter.string(from: deal.startDateTime)
        let toTime = timeFormatter.string(from: deal.endDateTime)
        
        var validityDate = ""
        if fromDate != toDate {
            validityDate = "\(fromDate) to \(toDate)"
        } else {
            validityDate = "\(fromDate)"
        }
        
        var validityTime = ""
        if deal.hasTime.value {
            validityTime = " from \(fromTime) to \(toTime)"
        }

        self.validityLabel.text = validityDate + validityTime
        
        /*
        let blueAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appDarkGrayColor()]
        
        let whiteAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                               NSAttributedStringKey.foregroundColor : UIColor.appDarkGrayColor()]
        
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
        */
    }

    //MARK IBActions
    @IBAction func viewBarDetailButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(barDetailFromFiveADayClick, parameters: nil)
        self.delegate.dealDetailCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate.dealDetailCell(cell: self, viewDirectionButtonTapped: sender)
    }
}


//MARK: DTAttributedTextContentViewDelegate
extension DealDetailTableViewCell: DTAttributedTextContentViewDelegate {
    
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
