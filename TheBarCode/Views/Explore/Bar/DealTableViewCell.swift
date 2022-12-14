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
    func dealTableViewCell(cell: DealTableViewCell, shareButtonTapped sender: UIButton)
}

class DealTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var bookmarkActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    weak var delegate: DealTableViewCellDelegate?
    
    var expirationTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.detailLabel.textColor = UIColor.white
        self.shareButton.tintColor = UIColor.appGrayColor()
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
        self.pageControl.isHidden = self.pageControl.numberOfPages <= 1
        
        self.titleLabel.text = explore.title.value
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        
        self.detailLabel.text = "\(explore.deals.value) deals available"
        
        self.locationIconImageView.isHidden = false
        self.distanceButton.isHidden = false
        self.detailLabel.isHidden = false
        self.validityLabel.isHidden = true
        
        self.bookmarkButton.isHidden = true
        self.shareButton.isHidden = true
        
        self.setupStatus(explore: explore)
        
        self.unlimitedRedemptionView.isHidden = !explore.currentlyUnlimitedRedemptionAllowed
        
        self.cartIconContainer.isHidden = !explore.isInAppPaymentOn.value
        self.deliveryOnlyLabel.isHidden = !explore.isDeliveryOnly.value
    }
    
    func setUpDealCell(deal: Deal, topPadding: Bool = true, bar: Bar) {
        
        self.cartIconContainer.isHidden = true
        self.coverImageView.isHidden = false
        self.pageControl.isHidden = true
        self.statusButton.isHidden = true
        self.pagerView.isHidden = true
        self.deliveryOnlyLabel.isHidden = true
        
        let url = URL(string: deal.imageUrl.value)
        coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        self.locationIconImageView.isHidden = true
        self.distanceButton.isHidden = true
        self.detailLabel.isHidden = true
        
        if deal.canShare.value {
            if deal.showSharingLoader {
                self.shareButton.isHidden = true
                self.sharingLoader.startAnimating()
            } else {
                self.shareButton.isHidden = false
                self.sharingLoader.stopAnimating()
            }
        } else {
            self.shareButton.isHidden = true
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
        
        //Voucher
        if deal.isVoucher.value {
            self.bookmarkButton.isHidden = true
            self.titleLabel.attributedText = getAttributedTitle(title: deal.title.value)
            
            let priceString = String(format: "%.2f", deal.voucherAmount.value ?? 0.0)
            self.priceLabel.text = "   \(bar.currencySymbol.value) " + priceString + "   "
            self.priceLabel.isHidden = deal.voucherAmount.value == 0.0
            
        } else {
            self.bookmarkButton.isHidden = false
            self.titleLabel.text = deal.title.value
            self.priceLabel.isHidden = true
        }
    }
    
    func startTimer(deal: Deal) {
        
        self.stopTimer()
        
        guard deal.shouldShowDate.value && deal.hasTime.value else {
            self.validityLabel.text = ""
            debugPrint("Validity could not be shown")
            return
        }
        
        let status = deal.getCurrentStatus()
        switch status.status {
        case .notStarted:
            var remainingSeconds = deal.getStartsInRemainingSeconds()
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
                } else {
                    self.stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                        self?.startTimer(deal: deal)
                    })
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
        case .started:
            var expiresInSeconds = deal.getExpiresInRemainingSeconds()
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: expiresInSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if expiresInSeconds > 0 {
                    expiresInSeconds -= 1
                    self.updateExpirationLabel(status: .started, remainingSeconds: expiresInSeconds)
                } else {
                    self.stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                        self?.startTimer(deal: deal)
                    })
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            self.updateExpirationLabel(status: .started, remainingSeconds: expiresInSeconds)
        case .expired:
            self.updateExpirationLabel(status: .expired, remainingSeconds: 0)
        }
    }
    
    func stopTimer() {
        self.expirationTimer?.invalidate()
        self.expirationTimer = nil
    }
    
    func updateExpirationLabel(status: DealStatus, remainingSeconds: Int) {
        switch status {
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
    
    func getAttributedTitle(title: String) -> NSMutableAttributedString {
                
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = .left
        paraStyle.paragraphSpacing = 5.0
        
        let attributesWhite: [NSAttributedStringKey: Any] = [.font: UIFont.appBoldFontOf(size: 16.0),
                                                             .foregroundColor: UIColor.white,
                                                             .paragraphStyle : paraStyle]
        
        let attributesBlue: [NSAttributedStringKey: Any] = [.font: UIFont.appBoldFontOf(size: 12.0),
                                                            .foregroundColor: UIColor.appBlueColor()]
                    
        let titleAttributedString = NSAttributedString(string: title, attributes: attributesWhite)
        let voucherAttributedString = NSAttributedString(string: "\nVOUCHER OFFER", attributes: attributesBlue)
                    
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(titleAttributedString)
        finalAttributedString.append(voucherAttributedString)
                
        return finalAttributedString
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate?.dealTableViewCell(cell: self, distanceButtonTapped: sender)
    }
    
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.delegate?.dealTableViewCell(cell: self, bookmarkButtonTapped: sender)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        self.delegate?.dealTableViewCell(cell: self, shareButtonTapped: sender)
    }
}

