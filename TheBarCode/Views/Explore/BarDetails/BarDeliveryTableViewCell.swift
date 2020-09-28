//
//  BarDeliveryTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 11/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol BarDeliveryTableViewCellDelegate: class {
    func barDeliveryTableViewCell(cell: BarDeliveryTableViewCell, showTimingButtonTapped sender: UIButton)
}

class BarDeliveryTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var placeholderLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
    @IBOutlet var moreTimingsButton: UIButton!
    
    @IBOutlet var placeholderLabelTop: NSLayoutConstraint!
    
    @IBOutlet var additionalInfoLabel: UILabel!
    
    weak var delegate: BarDeliveryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(bar: Bar) {
        
        self.statusLabel.text = bar.isDeliveryAvailable.value ? "Available" : "Temporarily Closed"
        
        if bar.deliveryExpanded {
            
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "HH:mm"
            
            let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.appLightGrayColor()]
            let boldAttributes = [NSAttributedString.Key.font : UIFont.appBoldFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.white]
            
            let image = UIImage(named: "icon_accordion_up")
            self.moreTimingsButton.setImage(image, for: .normal)
            
            self.placeholderLabelTop.constant = 8.0
            
            let attributedPlaceholder = NSMutableAttributedString()
            let attributedTiming = NSMutableAttributedString()
            
            for time in bar.deliverySchedule.value {
                
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
                
                if bar.hasFullDayDelivery.value {
                    let attributedTime = NSAttributedString(string: "00:00 - 23:59", attributes: attributes)
                    attributedTiming.append(attributedTime)
                } else if time.dayStatus == .unavailable {
                    let attributedStatus = NSAttributedString(string: "Closed", attributes: attributes)
                    attributedTiming.append(attributedStatus)
                } else {
                    let timingString = dateformatter.string(from: time.fromTime.value!) + " - " + dateformatter.string(from: time.toTime.value!)
                    
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
        
        
        let attributedAdditionalInfo = NSMutableAttributedString()
        
        var headingAttributes = [NSAttributedString.Key.font : UIFont.appBoldFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.appGrayColor()]
        var valueAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 0.0
        
        headingAttributes[NSAttributedString.Key.paragraphStyle] = paraStyle
        valueAttributes[NSAttributedString.Key.paragraphStyle] = paraStyle
        
        let conditionPlaceholder = NSAttributedString(string: "DELIVERY CONDITION", attributes: headingAttributes)
        let conditionValue = NSAttributedString(string: "\n\r" + bar.deliveryCondition.value, attributes: valueAttributes)
        
        if bar.deliveryCondition.value.count > 0 {
            attributedAdditionalInfo.append(conditionPlaceholder)
            attributedAdditionalInfo.append(conditionValue)
        }
        
        let spacing = bar.deliveryCondition.value.count > 0 ? "\n\r" : ""
        let vicinityPlaceholder = NSAttributedString(string: "\(spacing)DELIVERY VICINITY", attributes: headingAttributes)
        let vicinity = String(format: "%.1f %@", bar.deliveryRadius.value, bar.deliveryRadius.value > 1.0 ? "miles" : "mile")
        let vicinityValue = NSAttributedString(string: "\n\rWithin \(vicinity) radius", attributes: valueAttributes)

        attributedAdditionalInfo.append(vicinityPlaceholder)
        attributedAdditionalInfo.append(vicinityValue)
        
        self.additionalInfoLabel.attributedText = attributedAdditionalInfo
        
    }
    
    //MARK: My IBActions
    @IBAction func showTimingButtonTapped(sender: UIButton) {
        self.delegate?.barDeliveryTableViewCell(cell: self, showTimingButtonTapped: sender)
    }
    
}
