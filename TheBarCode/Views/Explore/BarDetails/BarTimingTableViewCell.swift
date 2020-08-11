//
//  BarTimingTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 11/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import Reusable

protocol BarTimingTableViewCellDelegate: class {
    func barTimingTableViewCell(cell: BarTimingTableViewCell, showTimingButtonTapped sender: UIButton)
}

class BarTimingTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var todayTimeLabel: UILabel!
    
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    @IBOutlet var moreTimingsButton: UIButton!
    
    @IBOutlet var placeholderLabelTop: NSLayoutConstraint!
    
    weak var delegate: BarTimingTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(bar: Bar) {
        self.setupOpeningStatus(bar: bar)
        self.setupWeekDaysTimings(bar: bar)
    }
    
    func setupOpeningStatus(bar: Bar) {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        
        if let timings = bar.timings.value {
            if timings.dayStatus == .closed {
                self.titleLabel.text = "CLOSED"
                self.titleLabel.textColor = UIColor.appRedColor()
                self.todayTimeLabel.text = ""
            } else {
                
                if timings.openingTime.value == nil || timings.closingTime.value == nil {
                    let params = ["opening_time" : timings.openingTimeRaw.value,
                                  "closing_time" : timings.closingTimeRaw.value,
                                  "bar_id" : bar.id.value]
                    Analytics.logEvent("bar_open_or_close_time_nil", parameters: params)
                }
                
                let timingString = dateformatter.string(from: timings.openingTime.value!) + " - " + dateformatter.string(from: timings.closingTime.value!)
                
                if timings.isOpen.value {
                    self.titleLabel.text = "OPEN"
                    self.titleLabel.textColor = UIColor.appBlueColor()
                    self.todayTimeLabel.text = timingString
                } else {
                    self.titleLabel.text = "CLOSED"
                    self.titleLabel.textColor = UIColor.appRedColor()
                    self.todayTimeLabel.text = timingString
                }
            }
            
        } else {
            self.titleLabel.text = "CLOSED"
            self.titleLabel.textColor = UIColor.appRedColor()
            self.todayTimeLabel.text = ""
        }
    }
    
    func setupWeekDaysTimings(bar: Bar) {
        
        let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.appLightGrayColor()]
        let boldAttributes = [NSAttributedString.Key.font : UIFont.appBoldFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        
        if bar.timingExpanded {
            
            let image = UIImage(named: "icon_accordion_up")
            self.moreTimingsButton.setImage(image, for: .normal)
            
            self.placeholderLabelTop.constant = 8.0
            
            let attributedPlaceholder = NSMutableAttributedString()
            let attributedTiming = NSMutableAttributedString()
            
            for time in bar.weeklySchedule.value {
                
                var attributes = time.day.value.lowercased() == bar.timings.value?.day.value.lowercased() ? boldAttributes : normalAttributes
                
                let leftAlignedParaStyle = NSMutableParagraphStyle()
                leftAlignedParaStyle.lineSpacing = 5.0
                leftAlignedParaStyle.alignment = .left
                attributes[NSAttributedStringKey.paragraphStyle] = leftAlignedParaStyle
                
                let attributedDay = NSAttributedString(string: time.day.value, attributes: attributes)
                attributedPlaceholder.append(attributedDay)
                
                let rightAlignedParaStyle = NSMutableParagraphStyle()
                rightAlignedParaStyle.lineSpacing = 5.0
                rightAlignedParaStyle.alignment = .right
                attributes[NSAttributedStringKey.paragraphStyle] = rightAlignedParaStyle
                
                if time.dayStatus == .closed {

                    let attributedStatus = NSAttributedString(string: "Closed", attributes: attributes)
                    attributedTiming.append(attributedStatus)
                    
                } else {
                    let timingString = dateformatter.string(from: time.openingTime.value!) + " - " + dateformatter.string(from: time.closingTime.value!)
                    
                    let attributedTime = NSAttributedString(string: timingString, attributes: attributes)
                    attributedTiming.append(attributedTime)
                }
                
                if time != bar.weeklySchedule.value.last {
                    let attributeNewLine = NSAttributedString(string: "\n", attributes: normalAttributes)
                    attributedPlaceholder.append(attributeNewLine)
                    attributedTiming.append(attributeNewLine)
                }
            }
            
            self.placeholderLabel.attributedText = attributedPlaceholder
            self.valueLabel.attributedText = attributedTiming
            
        } else {
            
            self.moreTimingsButton.setImage(UIImage(named: "icon_accordion"), for: .normal)
            
            self.placeholderLabelTop.constant = 0.0
            
            self.placeholderLabel.attributedText = NSAttributedString(string: "")
            self.valueLabel.attributedText = NSAttributedString(string: "")
        }
    }
    
    //MARK: My IBActions
    @IBAction func showTimingButtonTapped(sender: UIButton) {
        self.delegate?.barTimingTableViewCell(cell: self, showTimingButtonTapped: sender)
    }
}
