//
//  WhatsOnDetailEventCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol WhatsOnDetailEventCellDelegate: class {
    func whatsOnDetailEventCell(cell: WhatsOnDetailEventCell, directionsButtonTapped sender: UIButton)
}

class WhatsOnDetailEventCell: UITableViewCell, NibReusable {

    @IBOutlet var locationPlaceholderLabel: UILabel!
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var directionButton: UIButton!
    
    weak var delegate: WhatsOnDetailEventCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupEvent(event: Event, bar: Bar) {
        
        self.locationPlaceholderLabel.text = "Location:"
        
        self.dateLabel.text = event.formattedDateString
        self.locationLabel.text = event.locationName.value
        
        self.detailLabel.text = event.detail.value
        self.directionButton.setTitle("Get Driving Directions", for: .normal)
        
        self.setupValidityLabel(event: event)
    }
    
    func setupValidityLabel(event: Event) {
                
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        
        let validtyPlaceHodler = "Validity period: "
        
        let fromDate = dateFormatter.string(from: event.startDateTime)
        let toDate = dateFormatter.string(from: event.endDateTime)
        let to = " to "
        let from = " from "
        
        let fromTime = timeFormatter.string(from: event.startDateTime)
        let toTime = timeFormatter.string(from: event.endDateTime)
        
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

        
        self.dateLabel.attributedText = finalAttributedText
    }
    
    //MARK: My IBActions
    @IBAction func directionButtonTapped(sender: UIButton) {
        self.delegate.whatsOnDetailEventCell(cell: self, directionsButtonTapped: sender)
    }
}
