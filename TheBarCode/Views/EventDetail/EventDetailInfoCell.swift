//
//  EventDetailInfoCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol EventDetailInfoCellDelegate: class {
    func eventDetailInfoCell(cell: EventDetailInfoCell, directionButtonTapped sender: UIButton)
}

class EventDetailInfoCell: UITableViewCell, NibReusable {

    @IBOutlet var iconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var callToActionButton: UIButton!
    
    @IBOutlet var ctaHeight: NSLayoutConstraint!
    @IBOutlet var ctaTopMargin: NSLayoutConstraint!
    
    weak var delegate: EventDetailInfoCellDelegate!
    
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
    func setupCell(eventDetailInfo: EventDetailInfo) {
        self.titleLabel.text = eventDetailInfo.title.uppercased()
        self.detailLabel.attributedText = eventDetailInfo.detail
        
        UIView.performWithoutAnimation {
            if eventDetailInfo.showCallToAction {
                self.callToActionButton.isHidden = false
                self.ctaHeight.constant = 29.0
                self.ctaTopMargin.constant = 8.0
                self.callToActionButton.setTitle(eventDetailInfo.callToActionTitle, for: .normal)
            } else {
                self.callToActionButton.isHidden = true
                self.ctaHeight.constant = 0.0
                self.ctaTopMargin.constant = 0.0
                self.callToActionButton.setTitle("", for: .normal)
            }
            
            self.callToActionButton.layoutIfNeeded()
        }
    
        self.iconImageView.image = UIImage(named: eventDetailInfo.iconName)?.withRenderingMode(.alwaysTemplate)
    }
    
    //MARK: My IBActions
    @IBAction func callToActionButtonTapped(sender: UIButton) {
        self.delegate!.eventDetailInfoCell(cell: self, directionButtonTapped: sender)
    }
}
