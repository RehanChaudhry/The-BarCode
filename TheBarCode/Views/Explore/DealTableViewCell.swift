//
//  DealTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class DealTableViewCell: ExploreBaseTableViewCell, NibReusable {

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
        if explore.images.value.count > 0 {
            let url = explore.images.value[0].url.value
            coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
            
        }
        titleLabel.text = explore.title.value
        distanceLabel.text = explore.distance.value
        detailLabel.text = "\(explore.deals.value) deals available"
        
        locationIconImageView.isHidden = false
        distanceLabel.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
    }
    
    func setUpDealCell(deal: Deal) {
        let explore = deal.establishment.value!
        let url = deal.image.value
        coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
        titleLabel.text = explore.title.value
        locationIconImageView.isHidden = true
        distanceLabel.isHidden = true
        detailLabel.isHidden = true
        
        validityLabel.attributedText = getAttributedString(startTime: deal.startTime.value, endTime: deal.endTime.value)
    }
    
    
    func getAttributedString(startTime:String, endTime:String) -> NSMutableAttributedString {
        
        let font = UIFont.appRegularFontOf(size: 12.0)
        let attributesWhite: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.white]
        let attributesBlue: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.appBlueColor()]
        
        let description = "Validity Period"
        let text = NSMutableAttributedString(string: description, attributes: attributesWhite)
        
        let description1 = " \(startTime)"
        let text1 = NSMutableAttributedString(string: description1, attributes: attributesBlue)
        
        let description2 = " to "
        let text2 = NSMutableAttributedString(string: description2, attributes: attributesWhite)
        
        let description3 = "\(endTime)"
        let text3 = NSMutableAttributedString(string: description3, attributes: attributesBlue)
        
        text.append(text1)
        text.append(text2)
        text.append(text3)
        
        return text
        
    }
    
}
