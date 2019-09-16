//
//  ExploreAboutTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ExploreAboutTableViewCellDelegate: class {
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, websiteButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, directionsButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, callButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, emailButtonTapped sender: UIButton)
    func exploreAboutTableViewCell(cell: ExploreAboutTableViewCell, showButtonTapped sender: UIButton)
}

class ExploreAboutTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var websitePlaceholderLabel: UILabel!
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var timingPlaceholderLabel: UILabel!
    @IBOutlet var timingsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var websiteLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    
    @IBOutlet var websiteButton: UIButton!
    @IBOutlet var phoneNumberButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    @IBOutlet var directionsButton: UIButton!
    
    @IBOutlet var currentTimeHeaderLabel: UILabel!
    @IBOutlet var currentDayTimingLabel: UILabel!
    
    @IBOutlet var currentDayBottomMargin: NSLayoutConstraint!
    @IBOutlet var showMoreBottomMargin: NSLayoutConstraint!
    @IBOutlet var websitePlaceholderLabelHeight: NSLayoutConstraint!
    @IBOutlet var phonePlaceholderLabelTop: NSLayoutConstraint!
    @IBOutlet var phoneNumberLabelTop: NSLayoutConstraint!
    
    @IBOutlet var websiteButtonHeight: NSLayoutConstraint!
    @IBOutlet var phoneNumberButtonHeight: NSLayoutConstraint!
    @IBOutlet var emailButtonHeight: NSLayoutConstraint!

    @IBOutlet var showMoreTimingsButton: UIButton!
    
    weak var delegate: ExploreAboutTableViewCellDelegate!
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.websiteButtonHeight.constant = self.websiteLabel.frame.height
        self.phoneNumberButtonHeight.constant = self.phoneNumberLabel.frame.height
        self.emailButtonHeight.constant = self.emailLabel.frame.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .none
                
        self.emailLabel.isHidden = true
        self.websiteLabel.isHidden = true
        self.phoneNumberLabel.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    //MARK: My Methods
    
    func setUpCell(explore: Explore) {
        infoLabel.text = explore.detail.value
        timingsLabel.text = explore.businessTiming.value
        phoneNumberButton.setTitle(explore.contactNumber.value, for: .normal)
        addressLabel.text = explore.address.value
        emailButton.setTitle(explore.contactEmail.value, for: .normal)
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "HH:mm"
        
        let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.appLightGrayColor()]
        let boldAttributes = [NSAttributedString.Key.font : UIFont.appBoldFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if let timings = explore.timings.value {
            if timings.dayStatus == .closed {
                self.currentTimeHeaderLabel.text = "CLOSED"
                self.currentTimeHeaderLabel.textColor = UIColor.appRedColor()
                self.currentDayTimingLabel.text = ""
            } else {
                let timingString = dateformatter.string(from: timings.openingTime.value!) + " - " + dateformatter.string(from: timings.closingTime.value!)
                
                if timings.isOpen.value {
                    self.currentTimeHeaderLabel.text = "OPEN"
                    self.currentTimeHeaderLabel.textColor = UIColor.appBlueColor()
                    self.currentDayTimingLabel.text = timingString
                } else {
                    self.currentTimeHeaderLabel.text = "CLOSED"
                    self.currentTimeHeaderLabel.textColor = UIColor.appRedColor()
                    self.currentDayTimingLabel.text = timingString
                }
            }
            
        } else {
            self.currentTimeHeaderLabel.text = "CLOSED"
            self.currentTimeHeaderLabel.textColor = UIColor.appRedColor()
            self.currentDayTimingLabel.text = ""
        }
        
        if explore.timingExpanded {
            
            let image = UIImage(named: "icon_accordion_up")
            self.showMoreTimingsButton.setImage(image, for: .normal)
            
            self.showMoreBottomMargin.constant = 8.0
            self.currentDayBottomMargin.constant = 8.0
            
            let attributedPlaceholder = NSMutableAttributedString()
            let attributedTiming = NSMutableAttributedString()
            
            for time in explore.weeklySchedule.value {
                
                var attributes = time.day.value.lowercased() == explore.timings.value?.day.value.lowercased() ? boldAttributes : normalAttributes
                
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
                
                if time != explore.weeklySchedule.value.last {
                    let attributeNewLine = NSAttributedString(string: "\n", attributes: normalAttributes)
                    attributedPlaceholder.append(attributeNewLine)
                    attributedTiming.append(attributeNewLine)
                }
                
            }
            
            self.timingPlaceholderLabel.attributedText = attributedPlaceholder
            self.timingsLabel.attributedText = attributedTiming
            
        } else {
            
            self.showMoreTimingsButton.setImage(UIImage(named: "icon_accordion"), for: .normal)
            
            self.showMoreBottomMargin.constant = 0.0
            self.currentDayBottomMargin.constant = 0.0
            
            self.timingPlaceholderLabel.attributedText = NSAttributedString(string: "")
            self.timingsLabel.attributedText = NSAttributedString(string: "")
        }
        

        if explore.website.value == "" {
//            self.websitePlaceholderLabel.isHidden = true
//            self.websiteButton.isHidden = true
            self.websiteButton.setTitle("N/A", for: .normal)
            self.websiteButton.isUserInteractionEnabled = false
            
//            self.websiteButtonHeight.constant = 0.0
//            self.phonePlaceholderLabelTop.constant = 0.0
//            self.phoneNumberLabelTop.constant = 0.0
            
        } else {
//            self.websitePlaceholderLabel.isHidden = false
//            self.websiteButton.isHidden = false
            self.websiteButton.setTitle(explore.website.value, for: .normal)
            self.websiteButton.isUserInteractionEnabled = true
            
//            self.websiteButtonHeight.constant = 17.0
//            self.phonePlaceholderLabelTop.constant = 15.0
//            self.phoneNumberLabelTop.constant = 15.0
        }
    }
    
    //MARK: My IBActions
    @IBAction func websiteButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, websiteButtonTapped: sender)
    }
    
    @IBAction func callButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, callButtonTapped: sender)
    }
    
    @IBAction func emailButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, emailButtonTapped: sender)
    }
    
    @IBAction func directionsButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, directionsButtonTapped: sender)
    }
    
    @IBAction func showMoreButtonTapped(sender: UIButton) {
        self.delegate.exploreAboutTableViewCell(cell: self, showButtonTapped: sender)
    }
}
