//
//  DealDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 08/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol DealDetailTableViewCellDelegate: class {
    func dealDetailCell(cell: DealDetailTableViewCell, viewBarDetailButtonTapped sender: UIButton)
    func dealDetailCell(cell: DealDetailTableViewCell, viewDirectionButtonTapped sender: UIButton)
}

class DealDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
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
        
        self.detailLabel.text =  deal.detail.value
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
        timeFormatter.dateFormat = "hh:mm a"
        
//        let validtyPlaceHodler = "Validity period: "
        
        let fromDate = dateFormatter.string(from: deal.startDateTime)
        let toDate = dateFormatter.string(from: deal.endDateTime)
//        let to = " to "
//        let from = " from "
        
        let fromTime = timeFormatter.string(from: deal.startDateTime)
        let toTime = timeFormatter.string(from: deal.endDateTime)
        
        let validityDate = "Validity Date: \(fromDate) to \(toDate)"
        let validityTime = "Validity Time: \(fromTime) to \(toTime)"
        
        self.validityLabel.text = validityDate + "\n" + validityTime
        
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
        self.delegate.dealDetailCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        self.delegate.dealDetailCell(cell: self, viewDirectionButtonTapped: sender)
    }
}
