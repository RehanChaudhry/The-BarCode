//
//  FiveADayCollectionViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView

class FiveADayCollectionViewCell: FSPagerViewCell , NibReusable {
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var dealTitleLabel: UILabel!
    @IBOutlet weak var dealSubTitleLabel: UILabel!
    @IBOutlet weak var dealDetailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func setUpCell(deal: FiveADayDeal){
        self.coverImageView.image = UIImage(named: deal.coverImage)
        self.dealTitleLabel.text = deal.title.uppercased()
        self.dealSubTitleLabel.text = deal.subTitle
        self.dealDetailLabel.text = deal.detail
        self.locationLabel.text = deal.location
        self.distanceLabel.text = deal.distance
    }
    
    
}
