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

    @IBOutlet var datePlaceholderLabel: UILabel!
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
        
        self.datePlaceholderLabel.text = "Date:"
        self.locationPlaceholderLabel.text = "Location:"
        
        self.dateLabel.text = event.formattedDateString
        self.locationLabel.text = event.locationName.value
        
        self.detailLabel.text = event.detail.value
        self.directionButton.setTitle("Get Driving Directions", for: .normal)
    }
    
    //MARK: My IBActions
    @IBAction func directionButtonTapped(sender: UIButton) {
        self.delegate.whatsOnDetailEventCell(cell: self, directionsButtonTapped: sender)
    }
}
