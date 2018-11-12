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
        
        self.backgroundColor = UIColor.clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(offer: Deal) {
        self.offerTitleLabel.text = offer.title.value
        self.barTitleButton.setTitle(offer.establishment.value!.title.value, for: .normal)
        self.offerTypeLabel.text = (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: offer.establishment.value!.distance.value), for: .normal)
        let url = offer.image.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.sharedByLabel.attributedText =  self.attributedSharedBy(deal: offer)
    }
    
    func setUpCell(offer: LiveOffer) {
        self.offerTitleLabel.text = offer.title.value
        self.barTitleButton.setTitle(offer.establishment.value!.title.value, for: .normal)
        self.offerTypeLabel.text = (Utility.shared.checkDealType(offerTypeID: offer.offerTypeId.value)).rawValue.uppercased()
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: offer.establishment.value!.distance.value), for: .normal)
        let url = offer.image.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.sharedByLabel.attributedText =  self.attributedSharedBy(deal: offer)
        
    }
    
    func attributedSharedBy(deal: Deal) -> NSMutableAttributedString {
        let placeholderAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                     NSAttributedStringKey.foregroundColor : UIColor.white]
        let nameAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let placeholderAttributedString = NSMutableAttributedString(string: "Shared by: ", attributes: placeholderAttributes)
        let nameAttributedString = NSMutableAttributedString(string: deal.sharedByName.value ?? "", attributes: nameAttributes)
        
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
