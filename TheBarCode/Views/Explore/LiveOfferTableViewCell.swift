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
    
    //Timer
    var timer = Timer()
    var seconds = 43200
    
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
           // coverImageView.setImageWith(url: URL(string: image.url.value), showRetryButton: false)
            coverImageView.setImageWith(url: URL(string: image.url.value), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        }
        
        titleLabel.text = explore.title.value
        distanceLabel.text = Utility.shared.getformattedDistance(distance: explore.distance.value)
        detailLabel.text = "\(explore.deals.value) live offer"
        locationIconImageView.isHidden = false
        distanceLabel.isHidden = false
        detailLabel.isHidden = false
        validityLabel.isHidden = true
        
    }
    
    func setUpDetailCell(offer: LiveOffer) {
        
       // let explore = offer.establishment.value!
        let url = offer.image.value
       // coverImageView.setImageWith(url: URL(string: url), showRetryButton: false)
         coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        titleLabel.text = offer.title.value//explore.title.value
        locationIconImageView.isHidden = true
        distanceLabel.isHidden = true
        detailLabel.isHidden = true
        
        validityLabel.attributedText = getAttributedString(endTime: offer.endTimeRaw.value)
        
       // runTimer()
    }
    
    func getAttributedString(endTime:String) -> NSMutableAttributedString {
        
        let font = UIFont.appRegularFontOf(size: 12.0)
        let attributesWhite: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.white]
        let attributesBlue: [NSAttributedStringKey: Any] = [
            .font: font,
            .foregroundColor: UIColor.appBlueColor()]
        
        let description = "Expires in:"
        let text = NSMutableAttributedString(string: description, attributes: attributesWhite)

        let description1 = " \(endTime)"
        let text1 = NSMutableAttributedString(string: description1, attributes: attributesBlue)

        text.append(text1)
        
        return text
        
    }
    
}


extension LiveOfferTableViewCell {
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(LiveOfferTableViewCell.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds -= 1
        if seconds < 0 {
            timer.invalidate()
        }
        
        let timerString = Utility.shared.getFormattedRemainingTime(time: TimeInterval(seconds))
//        self.timerWithTextLabel.attributedText = getAttributedString(endTime:timerString)
        
    }
}
