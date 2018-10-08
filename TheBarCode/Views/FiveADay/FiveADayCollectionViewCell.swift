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
import Gradientable

class FiveADayCollectionViewCell: FSPagerViewCell , NibReusable {
    
    @IBOutlet var shadowView: ShadowView!
    
    @IBOutlet var coverImageView: UIImageView!
    
    @IBOutlet var dealTitleLabel: UILabel!
    @IBOutlet var dealSubTitleLabel: UILabel!
    @IBOutlet var dealDetailLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var redeemButton: GradientButton!
    
    @IBOutlet var coverImageHeight: NSLayoutConstraint!
    @IBOutlet var detailVerticalSpacing: NSLayoutConstraint!
    
    @IBOutlet var detailButton: UIButton!
    
    var delegate : FiveADayViewControllerDelegate?
    var index : Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImageView.roundCorners(corners: [.topLeft, .topRight], radius: self.shadowView.cornerRadius)
    }
    
    //MARK: My Methods
    
    func setUpCell(deal: FiveADayDeal, index: Int) {
        self.index = index
        self.coverImageView.image = UIImage(named: deal.coverImage)
        self.dealTitleLabel.text = deal.title.uppercased()
        self.dealSubTitleLabel.text = deal.subTitle
        self.dealDetailLabel.text = deal.detail
        self.locationLabel.text = deal.location
        self.distanceLabel.text = deal.distance

        if UIScreen.main.bounds.size.width == 320.0 {
            self.coverImageHeight.constant = 165.0
        } else {
            let coverHeight = ((220.0 / 302.0) * self.frame.width)
            self.coverImageHeight.constant = coverHeight
        }

        self.layoutIfNeeded()
        
        if self.dealDetailLabel.isTruncated {
            self.dealDetailLabel.isHidden = true
//            self.detailVerticalSpacing.constant = 8.0 + 29.0
            
            self.detailButton.isHidden = false
        } else {
            self.dealDetailLabel.isHidden = false
//            self.detailVerticalSpacing.constant = 8.0
            
            self.detailButton.isHidden = true
        }
    }
    
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        delegate?.showPopup()
    }
    
    @IBAction func viewDetailButtonTapped(_ sender: Any) {
        delegate?.showDealDetail(index: self.index)
    }
}
