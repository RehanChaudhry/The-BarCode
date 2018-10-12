//
//  ExploreTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class ExploreBaseTableViewCell: UITableViewCell {

    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var locationIconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.locationIconImageView.tintColor = UIColor.appBlueColor()
        self.locationIconImageView.image = #imageLiteral(resourceName: "icon_map").withRenderingMode(.alwaysTemplate)
        
        self.distanceLabel.textColor = UIColor.appBlueColor()
        
        self.titleLabel.textColor = UIColor.white
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(explore: Explore) {
        //TODO
//        coverImageView.image = UIImage(named: explore.coverImage)
//        titleLabel.text = explore.title
//        distanceLabel.text = explore.distance
//        
    }
}
