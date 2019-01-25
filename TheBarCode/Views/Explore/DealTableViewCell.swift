//
//  DealTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol DealTableViewCellDelegate: class {
    func dealTableViewCell(cell: DealTableViewCell, distanceButtonTapped sender: UIButton)
}

class DealTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    weak var delegate: DealTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    override func setUpCell(explore: Explore) {
        if explore.images.value.count > 0 {
            let url = explore.images.value[0].url.value
            self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
            
        }
        titleLabel.text = explore.title.value
        distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        
        detailLabel.text = "\(explore.deals.value) deals available"
        
        locationIconImageView.isHidden = false
        distanceButton.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
    }
    
    func setUpDealCell(deal: Deal) {
        let url = URL(string: deal.imageUrl.value)
        coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        titleLabel.text = deal.title.value//explore.title.value
        locationIconImageView.isHidden = true
        distanceButton.isHidden = true
        detailLabel.isHidden = true
        
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
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        self.delegate?.dealTableViewCell(cell: self, distanceButtonTapped: sender)
    }
}

