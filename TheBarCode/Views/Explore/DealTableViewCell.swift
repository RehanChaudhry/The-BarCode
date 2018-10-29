//
//  DealTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class DealTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
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
            //coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
            self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
            
        }
        titleLabel.text = explore.title.value
        distanceLabel.text = Utility.shared.getformattedDistance(distance: explore.distance.value)
        detailLabel.text = "\(explore.deals.value) deals available"
        
        locationIconImageView.isHidden = false
        distanceLabel.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
    }
    
    func setUpDealCell(deal: Deal) {
        let url = URL(string: deal.imageUrl.value)
        coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        titleLabel.text = deal.title.value//explore.title.value
        locationIconImageView.isHidden = true
        distanceLabel.isHidden = true
        detailLabel.isHidden = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm:a"
        
        let validtyPlaceHodler = "Validity period: "
        
        if deal.statusText.value.lowercased() == "active".lowercased() {
            
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
