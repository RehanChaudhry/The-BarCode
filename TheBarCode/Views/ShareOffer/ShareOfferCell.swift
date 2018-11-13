//
//  ShareOfferCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ShareOfferCellDelegate: class {
    func shareOfferCell(cell: ShareOfferCell, viewBarDetailButtonTapped sender: UIButton)
    func shareOfferCell(cell: ShareOfferCell, viewDirectionButtonTapped sender: UIButton)
}

class ShareOfferCell: UITableViewCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    @IBOutlet var offerTitleLabel: UILabel!    
    @IBOutlet var barTitleButton: UIButton!
    @IBOutlet var offerTypeLabel: UILabel!
    @IBOutlet var distanceButton: UIButton!
    @IBOutlet var sharedByLabel: UILabel!
    
    weak var delegate : ShareOfferCellDelegate!

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
        let url = offer.image.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.offerTypeLabel.attributedText = self.attributedString(prefixText: "Offer type: " ,Text: (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue.uppercased())
        self.sharedByLabel.attributedText =  self.attributedString(prefixText: "Shared by: ", Text:  offer.sharedByName.value ?? "")
    }
    
    func setUpCell(offer: LiveOffer) {
        self.offerTitleLabel.text = offer.title.value
        self.barTitleButton.setTitle(offer.establishment.value!.title.value, for: .normal)
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: offer.establishment.value!.distance.value), for: .normal)
        let url = offer.image.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.offerTypeLabel.attributedText = self.attributedString(prefixText: "Offer Type: " ,Text: (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue.uppercased())
        self.sharedByLabel.attributedText =  self.attributedString(prefixText: "Shared by: ", Text:  offer.sharedByName.value ?? "")
        
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
        self.delegate.shareOfferCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        self.delegate.shareOfferCell(cell: self, viewDirectionButtonTapped: sender)

    }
    
    
}
