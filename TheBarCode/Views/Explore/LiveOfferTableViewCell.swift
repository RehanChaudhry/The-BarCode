//
//  LiveOfferTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class LiveOfferTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    var expirationTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        self.stopTimer()
    }
    
    //MARK: My Methods
    
    override func setUpCell(explore: Explore) {
        
        if let image = explore.images.first {
           // coverImageView.setImageWith(url: URL(string: image.url.value), showRetryButton: false)
            coverImageView.setImageWith(url: URL(string: image.url.value), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        }
        
        titleLabel.text = explore.title.value
        distanceLabel.text = Utility.shared.getformattedDistance(distance: explore.distance.value)
        detailLabel.text = "\(explore.deals.value) live offer"
        locationIconImageView.isHidden = false
        distanceLabel.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
        
    }
    
    func setUpDetailCell(offer: LiveOffer) {
        
       // let explore = offer.establishment.value!
        let url = offer.image.value
       // coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
         coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        titleLabel.text = offer.title.value//explore.title.value
        locationIconImageView.isHidden = true
        distanceLabel.isHidden = true
        detailLabel.isHidden = true
        
        let endDate = offer.endDateTime
        let remainingSeconds = Int(endDate.timeIntervalSinceNow)
        
        self.updateExpirationLabel(isExpired: remainingSeconds <= 0, remainingSeconds: remainingSeconds)
    }
    
    func startTimer(deal: Deal) {
        
        let endDate = deal.endDateTime
        var remainingSeconds = Int(endDate.timeIntervalSinceNow)
        
        if remainingSeconds > 0 {
            self.updateExpirationLabel(isExpired: false, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(isExpired: false, remainingSeconds: remainingSeconds)
                } else {
                    self.updateExpirationLabel(isExpired: true, remainingSeconds: 0)
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            
        } else {
            self.updateExpirationLabel(isExpired: true, remainingSeconds: 0)
        }
        
    }
    
    func stopTimer() {
        self.expirationTimer?.invalidate()
        self.expirationTimer = nil
    }
    
    func updateExpirationLabel(isExpired: Bool, remainingSeconds: Int) {
        let validtyPlaceHodler = "Expires in: "
        if isExpired {
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
            
            let attributesBlue: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.appBlueColor()]
            
            let expirationString = Utility.shared.getFormattedRemainingTimeInHours(time: TimeInterval(remainingSeconds))
            
            let validityAttributedString = NSAttributedString(string: validtyPlaceHodler, attributes: attributesWhite)
            let expiredAttributedString = NSAttributedString(string: expirationString, attributes: attributesBlue)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(validityAttributedString)
            finalAttributedString.append(expiredAttributedString)
            
            self.validityLabel.attributedText = finalAttributedString
        }
    }
    
}
