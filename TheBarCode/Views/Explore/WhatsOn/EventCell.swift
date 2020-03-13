//
//  EventCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import MGSwipeTableCell

protocol EventCellDelegate: class {
    func eventCell(cell: EventCell, bookmarkButtonTapped sender: UIButton)
    func eventCell(cell: EventCell, shareButtonTapped sender: UIButton)
}

class EventCell: MGSwipeTableCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    @IBOutlet var subTitleTop: NSLayoutConstraint!
    @IBOutlet var subTitleHeight: NSLayoutConstraint!
    
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    
    @IBOutlet var bookmarkLoader: UIActivityIndicatorView!
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    var expirationTimer: Timer?
    
    weak var eventCellDelegate: EventCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(event: Event, topPadding: Bool = true, barName: String? = nil) {
        
        if event.savingBookmarkStatus {
            self.bookmarkButton.isHidden = true
            self.bookmarkLoader.startAnimating()
        } else {
            if event.isBookmarked.value {
                self.bookmarkButton.tintColor = UIColor.appBlueColor()
            } else {
                self.bookmarkButton.tintColor = UIColor.appGrayColor()
            }
            self.bookmarkLoader.stopAnimating()
            self.bookmarkButton.isHidden = false
        }
        
        self.shareButton.tintColor = UIColor.appGrayColor()
        
        if event.showSharingLoader {
            self.shareButton.isHidden = true
            self.sharingLoader.startAnimating()
        } else {
            self.shareButton.isHidden = false
            self.sharingLoader.stopAnimating()
        }
        
        if let barName = barName {
            self.subTitleLabel.text = barName
            self.subTitleTop.constant = 8.0
            self.subTitleHeight.constant = 15.0
        } else {
            self.subTitleLabel.text = ""
            self.subTitleTop.constant = 0.0
            self.subTitleHeight.constant = 0.0
        }
        
        self.titleLabel.text = event.name.value
        
        let url = URL(string: event.image.value)
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
            , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        self.topPadding.constant = topPadding ? 24.0 : 0.0
    }
    
    func setupTimer(remainingSeconds: Int, offerStatus: EventStatus, event: Event) {
        
        var secondsLeft = remainingSeconds
        
        self.stopTimer()
        self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            if secondsLeft > 0 {
                secondsLeft -= 1
                self.updateExpirationLabel(status: offerStatus, remainingSeconds: secondsLeft)
            } else {
                self.stopTimer()
                self.startTimer(event: event)
            }
        })
        RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
    }
    
    func startTimer(event: Event) {
        
        guard event.shouldShowDate.value && event.shouldShowTime.value else {
            self.detailLabel.text = ""
            return
        }
        
        let status = event.getCurrentStatus()
        switch status.status {
        case .notStarted:
            var remainingSeconds = event.getStartsInRemainingSeconds()
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
                } else {
                    self.stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                        self?.startTimer(event: event)
                    })
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: remainingSeconds)
        case .started:
            var expiresInSeconds = event.getExpiresInRemainingSeconds()
            self.updateExpirationLabel(status: .notStarted, remainingSeconds: expiresInSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                if expiresInSeconds > 0 {
                    expiresInSeconds -= 1
                    self.updateExpirationLabel(status: .started, remainingSeconds: expiresInSeconds)
                } else {
                    self.stopTimer()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                        self?.startTimer(event: event)
                    })
                }
            })
            RunLoop.current.add(self.expirationTimer!, forMode: .commonModes)
            self.updateExpirationLabel(status: .started, remainingSeconds: expiresInSeconds)
        case .expired:
            self.updateExpirationLabel(status: .expired, remainingSeconds: 0)
        }
        
        
        //Not started yet
        //Started but not expired
            //Starts in
            //Ends in
        //Expired
        
        //Not started yet
        /*
        if Date().compare(event.startDateTime) == .orderedAscending {
            debugPrint("Event is not started yet")
            
            let remainingSeconds = Int(event.startDateTime.timeIntervalSince(Date()))
            self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
            self.setupTimer(remainingSeconds: remainingSeconds, offerStatus: .notStarted, event: event)
        } else if Int(event.endDateTime.timeIntervalSinceNow) > 0 {

            let todayDateString = Utility.shared.serverDateFormattedString(date: Date())
            let todayOfferStartDateTimeString = todayDateString + " " + event.startTimeRaw.value
            let todayOfferEndDateTimeString = todayDateString + " " + event.endTimeRaw.value
            
            let todayOfferStartDateTime = Utility.shared.serverFormattedDateTime(date: todayOfferStartDateTimeString)
            let todayOfferEndDateTime = Utility.shared.serverFormattedDateTime(date: todayOfferEndDateTimeString)
            
            if Date().compare(todayOfferStartDateTime) == .orderedAscending {
                debugPrint("Event is started but for today its not started yet")
                
                let remainingSeconds = Int(todayOfferStartDateTime.timeIntervalSince(Date()))
                self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
                self.setupTimer(remainingSeconds: remainingSeconds, offerStatus: .notStarted, event: event)
            } else if Int(todayOfferEndDateTime.timeIntervalSinceNow) > 0 {
                
                debugPrint("Event is started and for day its in start/end time range")
                
                let remainingSeconds = Int(todayOfferEndDateTime.timeIntervalSinceNow)
                self.setupTimer(remainingSeconds: remainingSeconds, offerStatus: .started, event: event)
                self.updateExpirationLabel(offerStatus: .started, remainingSeconds: remainingSeconds)
            } else {
                
                let nextDayDateString = Utility.shared.serverDateFormattedString(date: Date().addingTimeInterval(24.0 * 60.0 * 60.0))
                let nextDayOfferStartDateTimeString = nextDayDateString + " " + event.startTimeRaw.value
                let nextDayOfferEndDateTimeString = nextDayDateString + " " + event.endTimeRaw.value
                
                let nextDayOfferStartDateTime = Utility.shared.serverFormattedDateTime(date: nextDayOfferStartDateTimeString)
                let nextDayOfferEndDateTime = Utility.shared.serverFormattedDateTime(date: nextDayOfferEndDateTimeString)
                
                if event.endDateTime.compare(nextDayOfferEndDateTime) == .orderedDescending {
                    let remainingSeconds = Int(nextDayOfferStartDateTime.timeIntervalSince(Date()))
                    self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
                    self.setupTimer(remainingSeconds: remainingSeconds, offerStatus: .notStarted, event: event)
                    debugPrint("Event is started but waiting for next day start time")
                } else {
                    self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
                    debugPrint("Event is started but nothing next")
                }
                
            }
            
        //Expired
        } else {
            self.updateExpirationLabel(offerStatus: .expired, remainingSeconds: 0)
            debugPrint("Event is expired")
        }
        */
        
        /*
        //Deal not started yet
        if Date().compare(event.startDateTime) == .orderedAscending {
            var remainingSeconds = Int(event.startDateTime.timeIntervalSince(Date()))
            self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
            self.expirationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                
                if remainingSeconds > 0 {
                    remainingSeconds -= 1
                    self.updateExpirationLabel(offerStatus: .notStarted, remainingSeconds: remainingSeconds)
                } else {
                    self.stopTimer()
                    var expiresInSeconds = Int(event.endDateTime.timeIntervalSinceNow)
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
            
            //Deal is not expired
        } else if Int(event.endDateTime.timeIntervalSinceNow) > 0 {
            var remainingSeconds = Int(event.endDateTime.timeIntervalSinceNow)
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
        }*/
    }
    
    func stopTimer() {
        self.expirationTimer?.invalidate()
        self.expirationTimer = nil
    }

    func updateExpirationLabel(status: EventStatus, remainingSeconds: Int) {
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
            
            self.detailLabel.attributedText = finalAttributedString
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
            
            self.detailLabel.attributedText = finalAttributedString
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
            
            self.detailLabel.attributedText = finalAttributedString
        }
    }
    
    //MARK: My IBActions
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.eventCellDelegate.eventCell(cell: self, bookmarkButtonTapped: sender)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        self.eventCellDelegate.eventCell(cell: self, shareButtonTapped: sender)
    }
}
