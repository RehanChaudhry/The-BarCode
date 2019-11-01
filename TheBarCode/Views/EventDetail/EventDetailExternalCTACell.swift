//
//  EventDetailExternalCTACell.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol EventDetailExternalCTACellDelegate: class {
    func eventDetailExternalCTACell(cell: EventDetailExternalCTACell, ctaButtonTapped sender: UIButton)
}

class EventDetailExternalCTACell: UITableViewCell, NibReusable {

    @IBOutlet var callToActionButton: UIButton!
    
    weak var delegate: EventDetailExternalCTACellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(cta: EventExternalCTA) {
        UIView.performWithoutAnimation {
            self.callToActionButton.setTitle(cta.placeholder.value, for: .normal)
            self.callToActionButton.layoutIfNeeded()
        }
    }
    
    //MARK: My IBActions
    @IBAction func ctaButtonTapped(sender: UIButton) {
        self.delegate.eventDetailExternalCTACell(cell: self, ctaButtonTapped: sender)
    }
}
