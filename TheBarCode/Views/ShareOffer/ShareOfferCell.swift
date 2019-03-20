//
//  ShareOfferCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import MGSwipeTableCell
import FirebaseAnalytics

protocol ShareOfferCellDelegate: class {
    func shareOfferCell(cell: ShareOfferCell, viewBarDetailButtonTapped sender: UIButton)
    func shareOfferCell(cell: ShareOfferCell, viewDirectionButtonTapped sender: UIButton)
    func shareOfferCell(cell: ShareOfferCell, deleteButtonTapped sender: MGSwipeButton)
}

class ShareOfferCell: MGSwipeTableCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    @IBOutlet var offerTitleLabel: UILabel!    
    @IBOutlet var barTitleButton: UIButton!
    @IBOutlet var offerTypeLabel: UILabel!
    @IBOutlet var distanceButton: UIButton!
    @IBOutlet var sharedByLabel: UILabel!
    
    weak var sharingDelegate : ShareOfferCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(offer: Deal) {
        self.offerTitleLabel.text = offer.title.value
        self.barTitleButton.setTitle(offer.establishment.value!.title.value, for: .normal)
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: offer.establishment.value!.distance.value), for: .normal)
        let url = offer.imageUrl.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.offerTypeLabel.attributedText = self.attributedString(prefixText: "Offer type: " ,Text: (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue.uppercased())
        self.sharedByLabel.attributedText =  self.attributedString(prefixText: "Shared by: ", Text:  offer.sharedByName.value ?? "")
        
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "icon_trash"), backgroundColor: nil) { (cell) -> Bool in
            self.sharingDelegate.shareOfferCell(cell: cell as! ShareOfferCell, deleteButtonTapped: cell.rightButtons.first as! MGSwipeButton)
            return true
        }
        self.rightButtons = [deleteButton]
    }
    
    func setUpCell(offer: LiveOffer) {
        self.offerTitleLabel.text = offer.title.value
        self.barTitleButton.setTitle(offer.establishment.value!.title.value, for: .normal)
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: offer.establishment.value!.distance.value), for: .normal)
        let url = offer.imageUrl.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.offerTypeLabel.attributedText = self.attributedString(prefixText: "Offer Type: " ,Text: (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue.uppercased())
        self.sharedByLabel.attributedText =  self.attributedString(prefixText: "Shared by: ", Text:  offer.sharedByName.value ?? "")
        
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "icon_trash"), backgroundColor: nil) { (cell) -> Bool in
            self.sharingDelegate.shareOfferCell(cell: cell as! ShareOfferCell, deleteButtonTapped: cell.rightButtons.first as! MGSwipeButton)
            return true
        }
        self.rightButtons = [deleteButton]
    }
    
    func attributedString(prefixText: String, Text: String) -> NSMutableAttributedString {
        let placeholderAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                     NSAttributedStringKey.foregroundColor : UIColor.white]
        let nameAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let placeholderAttributedString = NSMutableAttributedString(string: prefixText, attributes: placeholderAttributes)
        let nameAttributedString = NSMutableAttributedString(string: Text, attributes: nameAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(placeholderAttributedString)
        finalAttributedString.append(nameAttributedString)
        return finalAttributedString
        
    }
    
    @IBAction func barNameButtonTapped(_ sender: UIButton) {
        self.sharingDelegate.shareOfferCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.sharingDelegate.shareOfferCell(cell: self, viewDirectionButtonTapped: sender)

    }
    
    
}
