//
//  LiveOfferTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class LiveOfferTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    override func setUpCell(explore: Explore) {
        
        if let image = explore.images.first {
            coverImageView.setImageWith(url: URL(string: image.url.value), showRetryButton: false)
        }
        
        titleLabel.text = explore.title.value
        distanceLabel.text = explore.distance.value
        detailLabel.text = "\(explore.deals.value) live offer"
        locationIconImageView.isHidden = false
        distanceLabel.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
        
    }
    
    func setUpDetailCell(offer: LiveOffer) {
        
        let explore = offer.establishment.value!
        let url = offer.image.value
        coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
            
        titleLabel.text = explore.title.value
        locationIconImageView.isHidden = true
        distanceLabel.isHidden = true
        detailLabel.isHidden = true
        
        validityLabel.attributedText = getAttributedString(startTime: offer.endTime.value)
    }
    
    func getAttributedString(startTime:String) -> NSMutableAttributedString {
        
        let font = UIFont.appRegularFontOf(size: 12.0)
        let attributesWhite: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.white]
        let attributesBlue: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.appBlueColor()]
        
        let description = "Expires in:"
        let text = NSMutableAttributedString(string: description, attributes: attributesWhite)

        let description1 = " \(startTime)"
        let text1 = NSMutableAttributedString(string: description1, attributes: attributesBlue)

        text.append(text1)
        
        return text
        
    }
    
}
