//
//  DealTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FirebaseAnalytics

protocol DealTableViewCellDelegate: class {
    func dealTableViewCell(cell: DealTableViewCell, distanceButtonTapped sender: UIButton)
    func dealTableViewCell(cell: DealTableViewCell, bookmarkButtonTapped sender: UIButton)
}

class DealTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    @IBOutlet var bookmarkButton: UIButton!
    
    @IBOutlet var bookmarkActivityIndicator: UIActivityIndicatorView!
    
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
        
        self.bar = explore
        self.pagerView.reloadData()
        
        self.pageControl.numberOfPages = self.bar?.images.count ?? 0
        self.pageControl.isHidden = self.pageControl.numberOfPages <= 1
        
        self.titleLabel.text = explore.title.value
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        
        self.detailLabel.text = "\(explore.deals.value) deals available"
        
        self.locationIconImageView.isHidden = false
        self.distanceButton.isHidden = false
        self.detailLabel.isHidden = false
        self.validityLabel.isHidden = true
        
        self.bookmarkButton.isHidden = true
        
        self.setupStatus(explore: explore)
    }
    
    func setUpDealCell(deal: Deal, topPadding: Bool = true) {
        
        self.coverImageView.isHidden = false
        self.pageControl.isHidden = true
        self.statusButton.isHidden = true
        self.pagerView.isHidden = true
        
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

        if !deal.shouldShowDate.value {
            self.validityLabel.text = ""
        } else if deal.statusText.value.lowercased() == "active".lowercased() {
            
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
        
        if deal.savingBookmarkStatus {
            self.bookmarkButton.isHidden = true
            self.bookmarkActivityIndicator.startAnimating()
        } else {
            if deal.isBookmarked.value {
                self.bookmarkButton.tintColor = UIColor.appBlueColor()
            } else {
                self.bookmarkButton.tintColor = UIColor.appGrayColor()
            }
            self.bookmarkActivityIndicator.stopAnimating()
            self.bookmarkButton.isHidden = false
        }
        
        self.topPadding.constant = topPadding ? 24.0 : 0.0
        
        
        
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate?.dealTableViewCell(cell: self, distanceButtonTapped: sender)
    }
    
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.delegate?.dealTableViewCell(cell: self, bookmarkButtonTapped: sender)
    }
}

