//
//  FiveADayCollectionViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView
import Gradientable
import FirebaseAnalytics

protocol FiveADayCollectionViewCellDelegate: class {
    func fiveADayCell(cell: FiveADayCollectionViewCell, redeemedButtonTapped sender: UIButton)
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDetailButtonTapped sender: UIButton)
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewBarDetailButtonTapped sender: UIButton)
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDirectionButtonTapped sender: UIButton)
    func fiveADayCell(cell: FiveADayCollectionViewCell, shareButtonTapped sender: UIButton)
}

class FiveADayCollectionViewCell: FSPagerViewCell , NibReusable {
    
    @IBOutlet var shadowView: ShadowView!
    
    @IBOutlet weak var barTitleButton: UIButton!
    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var dealTitleButton: UIButton!
    @IBOutlet var dealSubTitleButton: UIButton!
    
    @IBOutlet var dealDetailLabel: UILabel!
    @IBOutlet var barNameButton: UIButton!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var redeemButton: GradientButton!
    
    @IBOutlet var shareButtonContainer: ShadowView!
    @IBOutlet var shareButton: UIButton!
    
    @IBOutlet var coverImageHeight: NSLayoutConstraint!
    
    @IBOutlet var detailButton: UIButton!
    
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    weak var delegate : FiveADayCollectionViewCellDelegate!

    var expirationTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImageView.roundCorners(corners: [.topLeft, .topRight], radius: self.shadowView.cornerRadius)
    }
    
    deinit {
        self.stopTimer()
    }
    
    //MARK: My Methods
    
    func setUpCell(deal: Deal) {
        
        guard let bar = deal.establishment.value else {
            debugPrint("Bar info is not available")
            return
        }
        
        if deal.showSharingLoader {
            self.sharingLoader.startAnimating()
            self.shareButton.isHidden = true
        } else {
            self.sharingLoader.stopAnimating()
            self.shareButton.isHidden = false
        }
    
        if deal.showLoader {
            self.redeemButton.showLoader()
        } else {
            self.redeemButton.hideLoader()
        }
        
        if bar.canRedeemOffer.value || bar.currentlyUnlimitedRedemptionAllowed {
            self.redeemButton.updateColor(withGrey: false)
        } else {
            self.redeemButton.updateColor(withGrey: true)
        }
        
        self.coverImageView.setImageWith(url: URL(string: deal.imageUrl.value), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        self.dealTitleButton.setTitle(deal.subTitle.value.uppercased(), for: .normal)
        self.dealSubTitleButton.setTitle(deal.title.value, for: .normal)
        self.dealDetailLabel.text = deal.detail.value
        self.barNameButton.setTitle(deal.establishment.value!.title.value, for: .normal)
    self.barTitleButton.setTitle(deal.establishment.value!.title.value.uppercased(), for: .normal)
        
        if let distance = deal.establishment.value?.distance {
            self.distanceLabel.isHidden = false
            self.distanceLabel.text = Utility.shared.getformattedDistance(distance: distance.value)
        } else {
            self.distanceLabel.isHidden = true
            self.distanceLabel.text = ""
        }
 
        if UIScreen.main.bounds.size.width == 320.0 {
            self.coverImageHeight.constant = 165.0
        } else {
            let coverHeight = ((220.0 / 302.0) * self.frame.width)
            self.coverImageHeight.constant = coverHeight
        }

        self.layoutIfNeeded()
        
        if self.dealDetailLabel.isTruncated {
            self.detailButton.isHidden = false
        } else {
            self.detailButton.isHidden = true
        }
        
    }
    
    func startTimer(deal: Deal) {
        
        self.stopTimer()
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
            UIView.performWithoutAnimation {
                self.redeemButton.isEnabled = false
                self.redeemButton.setTitle("Starts in \(Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds)))", for: .normal)
                self.redeemButton.layoutIfNeeded()
            }
        case .started:
            UIView.performWithoutAnimation {
                self.redeemButton.isEnabled = true
                self.redeemButton.setTitle("Redeem Deal", for: .normal)
                self.redeemButton.layoutIfNeeded()
            }
            
        case .expired:
            UIView.performWithoutAnimation {
                self.redeemButton.isEnabled = false
                self.redeemButton.setTitle("Expired", for: .normal)
                self.redeemButton.layoutIfNeeded()
            }
        }
    }
    
//    func setUpRedeemButton(deal: Deal) {
//
//        let dateformatter = DateFormatter()
//        dateformatter.timeZone = serverTimeZone
//
//        var currentDate = Date()
//        dateformatter.dateFormat = serverDateFormat + " " + serverTimeFormat
//        currentDate = dateformatter.date(from: dateformatter.string(from: currentDate))!
//        currentDate = currentDate.addingTimeInterval(-(6.0 * 60.0 * 60.0))
//
//        dateformatter.dateFormat = serverDateFormat
//        let nowDate = dateformatter.date(from: dateformatter.string(from: currentDate))!
//        let nowDateString = dateformatter.string(from: nowDate)
//
//        dateformatter.dateFormat = serverTimeFormat
//        let nowTime = dateformatter.date(from: dateformatter.string(from: Date()))!
//        let nowTimeString = dateformatter.string(from: nowTime)
//
//        dateformatter.dateFormat = serverDateFormat + " " + serverTimeFormat
//        let nowDateTimeString = nowDateString + " " + nowTimeString
//        let nowDateTime = dateformatter.date(from: nowDateTimeString)!
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = serverTimeFormat
//
//        let currentTime = dateFormatter.date(from: dateFormatter.string(from: nowDateTime))!
//
//        let dealStartTime = dateFormatter.date(from: dateFormatter.string(from: deal.startDateTime))!
//        let dealEndTime = dateFormatter.date(from: dateFormatter.string(from: deal.endDateTime))!
//
//        let isDateInRange = nowDateTime.isDate(inRange: deal.startDateTime, toDate: deal.endDateTime, inclusive: true)
//
//        let isTimeInRange = currentTime.isDate(inRange: deal.startTime, toDate: deal.endTime, inclusive: true)
//
//        //Can redeem deal (With in date and time range)
//        if isDateInRange && isTimeInRange {
//
//            UIView.performWithoutAnimation {
//                self.redeemButton.isUserInteractionEnabled = true
//                self.redeemButton.setTitle("Redeem Deal", for: .normal)
//                self.redeemButton.layoutIfNeeded()
//            }
//
//        } else {
//
//            //Deal not started yet
//            if Date().compare(deal.startDateTime) == .orderedAscending {
//                var remainingSeconds = Int(deal.startDateTime.timeIntervalSince(Date())) + 1
//
//                self.updateStartsIn(timerFinished: false, remainingSeconds: remainingSeconds)
//                self.startInTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//                    if remainingSeconds > 0 {
//                        remainingSeconds -= 1
//                        self.updateStartsIn(timerFinished: false, remainingSeconds: remainingSeconds)
//                    } else {
//                        self.updateStartsIn(timerFinished: true, remainingSeconds: remainingSeconds)
//                    }
//                })
//
//                RunLoop.current.add(self.startInTimer!, forMode: .commonModes)
//            }
//            //Deal expired
//            else if Date().compare(deal.endDateTime) == .orderedDescending {
//                debugPrint("Deal expired")
//
//                UIView.performWithoutAnimation {
//                    self.redeemButton.isUserInteractionEnabled = false
//                    self.redeemButton.setTitle("Deal Expired", for: .normal)
//                    self.redeemButton.layoutIfNeeded()
//                }
//
//            } else {
//
//                dateFormatter.dateFormat = serverDateFormat
//                let todayDateString = dateFormatter.string(from: Date())
//
//                dateFormatter.dateFormat = serverTimeFormat
//                let dealStartTime = dateFormatter.string(from: dealStartTime)
//
//                let todayDealDateTimeString = todayDateString + " " + dealStartTime
//
//                dateFormatter.dateFormat = serverDateTimeFormat
//                let todayDealDateTime = dateFormatter.date(from: todayDealDateTimeString)!
//
//                var remainingSeconds: Int = 0
//                if Date().compare(todayDealDateTime) == .orderedAscending {
//                    remainingSeconds = Int(todayDealDateTime.timeIntervalSinceNow)
//                } else {
//                    let nextDayDateTime = todayDealDateTime.addingTimeInterval(60.0 * 60.0 * 24.0)
//                    remainingSeconds = Int(nextDayDateTime.timeIntervalSinceNow)
//                }
//
//                if remainingSeconds > 0 {
//                    self.updateStartsIn(timerFinished: false, remainingSeconds: remainingSeconds)
//                    self.startInTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
//                        if remainingSeconds > 0 {
//                            remainingSeconds -= 1
//                            self.updateStartsIn(timerFinished: false, remainingSeconds: remainingSeconds)
//                        } else {
//                            self.updateStartsIn(timerFinished: true, remainingSeconds: remainingSeconds)
//                        }
//                    })
//                    RunLoop.current.add(self.startInTimer!, forMode: .commonModes)
//                } else {
//                    debugPrint("cannot start timer")
//                    self.updateStartsIn(timerFinished: true, remainingSeconds: remainingSeconds)
//                }
//            }
//        }
//    }
//
//    func stopTimer() {
//        self.startInTimer?.invalidate()
//        self.startInTimer = nil
//    }
//
//    func updateStartsIn(timerFinished: Bool, remainingSeconds: Int) {
//
//        if timerFinished {
//            self.stopTimer()
//
//            self.redeemButton.isUserInteractionEnabled = true
//            self.redeemButton.setTitle("Redeem Deal", for: .normal)
//            self.redeemButton.layoutIfNeeded()
//
//        } else {
//            UIView.performWithoutAnimation {
//                self.redeemButton.isUserInteractionEnabled = false
//                self.redeemButton.setTitle("Starts in \(Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds)))", for: .normal)
//                self.redeemButton.layoutIfNeeded()
//            }
//        }
//    }
    
    //MARK: My IBActions
    @IBAction func redeemDealButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(redeemOfferButtonClick, parameters: nil)
        self.delegate!.fiveADayCell(cell: self, redeemedButtonTapped: sender)
    }
    
    @IBAction func viewDetailButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(offerDetailFromFiveADayClick, parameters: nil)
        self.delegate.fiveADayCell(cell: self, viewDetailButtonTapped: sender)
    }
    
    @IBAction func viewBarDetailButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(barDetailFromFiveADayClick, parameters: nil)
        self.delegate.fiveADayCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate.fiveADayCell(cell: self, viewDirectionButtonTapped: sender)
    }
    
    @IBAction func shareOfferButtonTapped(sender: UIButton) {
        Analytics.logEvent(fiveADayShareClick, parameters: nil)
        self.delegate.fiveADayCell(cell: self, shareButtonTapped: sender)
    }
}
