//
//  BarTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FirebaseAnalytics

protocol BarTableViewCellDelegare: class {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton)
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton)

}

class BarTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var favouriteButton: UIButton!
    
    @IBOutlet var bottomPadding: NSLayoutConstraint!
    
    @IBOutlet var deliverRadiusLabel: UILabel!
    
    weak var delegate : BarTableViewCellDelegare!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.favouriteButton.tintColor = UIColor.appLightGrayColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func setUpCell(bar: Bar, topPadding: Bool = true, bottomPadding: Bool = false, showDeliveryRadius: Bool = false) {
        super.setUpCell(explore: bar)
        self.favouriteButton.tintColor = bar.isUserFavourite.value ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
        
        if showDeliveryRadius {
            let vicinity = String(format: "%.1f %@", bar.deliveryRadius.value, bar.deliveryRadius.value > 1.0 ? "miles" : "mile")
            let vicinityValue = String("Within \(vicinity) radius")
            
            self.deliverRadiusLabel.text = vicinityValue
        } else {
            self.deliverRadiusLabel.text = ""
        }
        
        self.deliverRadiusLabel.textColor = UIColor.white
        self.deliverRadiusLabel.isHidden = !showDeliveryRadius
        self.favouriteButton.isHidden = showDeliveryRadius
        
        self.topPadding.constant = topPadding ? 24.0 : 0.0
        self.bottomPadding.constant = bottomPadding ? 10.0 : 1.0
    }
    
    //MARK: IBAction
    
    @IBAction func favouriteButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(markABarAsFavorite, parameters: nil)
        self.delegate!.barTableViewCell(cell: self, favouriteButton: sender)
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        Analytics.logEvent(locationMapClick, parameters: nil)
        self.delegate.barTableViewCell(cell: self, distanceButtonTapped: sender)
    }
}


