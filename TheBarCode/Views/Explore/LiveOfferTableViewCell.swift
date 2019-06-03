//
//  LiveOfferTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FirebaseAnalytics

protocol LiveOfferTableViewCellDelegate: class {
    func liveOfferCell(cell: LiveOfferTableViewCell, shareButtonTapped sender: UIButton)
    func liveOfferCell(cell: LiveOfferTableViewCell, distanceButtonTapped sender: UIButton)
}

class LiveOfferTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    var expirationTimer: Timer?
    
    weak var delegate: LiveOfferTableViewCellDelegate?
    
    enum LiveOfferStatus: String {
        case notStarted = "notStarted", started = "started", expired = "expired"
    }
    
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
        
        self.bar = explore
        self.pagerView.reloadData()
        
        self.pageControl.numberOfPages = self.bar?.images.count ?? 0
        
        self.titleLabel.text = explore.title.value
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        self.detailLabel.text = "\(explore.liveOffers.value) live offer"
        self.locationIconImageView.isHidden = false
        self.distanceButton.isHidden = false
        self.detailLabel.isHidden = false
        self.validityLabel.isHidden = true
     
        self.shareButton.isHidden = true
        
        self.setupStatus(explore: explore)
    }
    
    func setUpDetailCell(offer: LiveOffer, hideShare: Bool = false) {
        
        self.coverImageView.isHidden = false
        self.pagerView.isHidden = true
        self.pageControl.isHidden = true
        self.statusButton.isHidden = true
        
        let url = offer.imageUrl.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.titleLabel.text = offer.title.value
        self.locationIconImageView.isHidden = true
        self.distanceButton.isHidden = true
        self.detailLabel.isHidden = true
        
        if offer.canShare.value {
            if hideShare {
                self.shareButton.isHidden = true
            } else {
                if offer.showSharingLoader {
                    self.shareButton.isHidden = true
                    self.sharingLoader.startAnimating()
                } else {
                    self.shareButton.isHidden = false
                    self.sharingLoader.stopAnimating()
                }
            }
        } else {
            self.shareButton.isHidden = true
        }
        
   
        
//        let endDate = offer.endDateTime
//        let remainingSeconds = Int(endDate.timeIntervalSinceNow)
//
//        self.updateExpirationLabel(isExpired: remainingSeconds <= 0, remainingSeconds: remainingSeconds)
    }
    
    func attributedSharedBy(deal: Deal) -> NSMutableAttributedString {
        let placeholderAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                     NSAttributedStringKey.foregroundColor : UIColor.white]
        let nameAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let placeholderAttributedString = NSMutableAttributedString(string: "Shared by: ", attributes: placeholderAttributes)
        let nameAttributedString = NSMutableAttributedString(string: deal.sharedByName.value ?? "", attributes: nameAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(placeholderAttributedString)
        finalAttributedString.append(nameAttributedString)
        return finalAttributedString
        
    }
    
    func startTimer(deal: Deal) {
        
        //Deal not started yet
        if Date().compare(deal.startDateTime) == .orderedAscending {
            var remainingSeconds = Int(deal.startDateTime.timeIntervalSince(Date()))
            self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
                } else {
                    self.stopTimer()
                    var expiresInSeconds = Int(deal.endDateTime.timeIntervalSinceNow)
                    if expiresInSeconds > 0 {
                        self.updateExpirationLabel(offerStatus: .started, remainingSeconds: expiresInSeconds)
                        self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                            if expiresInSeconds > 0 {
                                expiresInSeconds -= 1
                                self.updateExpirationLabel(offerStatus: .started, remainingSeconds: expiresInSeconds)
                            } else {
                                self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
                            }
                        })
                        RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
                    } else {
                        self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
                    }
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            
        } else if Int(deal.endDateTime.timeIntervalSinceNow) > 0 {
            var remainingSeconds = Int(deal.endDateTime.timeIntervalSinceNow)
            self.updateExpirationLabel(offerStatus: .started, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(offerStatus: .started, remainingSeconds: remainingSeconds)
                } else {
                    self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
        } else {
            self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
        }
    }
    
    func stopTimer() {
        self.expirationTimer?.invalidate()
        self.expirationTimer = nil
    }
    
    func updateExpirationLabel(offerStatus: LiveOfferStatus, remainingSeconds: Int) {
        switch offerStatus {
        case .notStarted:
            let validtyPlaceHodler = "Starts in: "
            let attributesWhite: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.white]
            
            let attributesBlue: [NSAttributedStringKey: Any] = [
                .font: UIFont.appRegularFontOf(size: 12.0),
                .foregroundColor: UIColor.appBlueColor()]
            
            let expirationString = Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds))
            
            let validityAttributedString = NSAttributedString(string: validtyPlaceHodler, attributes: attributesWhite)
            let expiredAttributedString = NSAttributedString(string: expirationString, attributes: attributesBlue)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(validityAttributedString)
            finalAttributedString.append(expiredAttributedString)
            
            self.validityLabel.attributedText = finalAttributedString
        case .started:
            let validtyPlaceHodler = "Expires in: "
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
        case .expired:
            let validtyPlaceHodler = "Expires in: "
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
        }
    }
    
    /*
    func updateExpirationLabel(isStarted: Bool, isExpired: Bool, remainingSeconds: Int) {
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
    }*/
    
    //MARK: My IBActions
    
    @IBAction func shareOfferButtonTapped(sender: UIButton) {
        self.delegate?.liveOfferCell(cell: self, shareButtonTapped: sender)
    }
    
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate?.liveOfferCell(cell: self, distanceButtonTapped: sender)
    }
}
