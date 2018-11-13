//
//  ExploreTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class ExploreBaseTableViewCell: UITableViewCell {

    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var locationIconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var distanceButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.locationIconImageView.tintColor = UIColor.appBlueColor()
        self.locationIconImageView.image = #imageLiteral(resourceName: "icon_map").withRenderingMode(.alwaysTemplate)
    self.distanceButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.titleLabel.textColor = UIColor.white
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(explore: Explore) {
        if explore.images.value.count > 0 {
            let url = explore.images.value[0].url.value
            self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)

        }
        titleLabel.text = explore.title.value
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        
        locationIconImageView.isHidden = false
    }
        
}
