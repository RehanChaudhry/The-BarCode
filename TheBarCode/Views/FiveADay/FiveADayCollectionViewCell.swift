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

protocol FiveADayCollectionViewCellDelegate: class {
    func fiveADayCell(cell: FiveADayCollectionViewCell, redeemedButtonTapped sender: UIButton)
    func fiveADayCell(cell: FiveADayCollectionViewCell, viewDetailButtonTapped sender: UIButton)
}

class FiveADayCollectionViewCell: FSPagerViewCell , NibReusable {
    
    @IBOutlet var shadowView: ShadowView!
    
    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var dealTitleLabel: UILabel!
    @IBOutlet var dealSubTitleLabel: UILabel!
    @IBOutlet var dealDetailLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    @IBOutlet var redeemButton: GradientButton!
    
    @IBOutlet var coverImageHeight: NSLayoutConstraint!
    @IBOutlet var detailVerticalSpacing: NSLayoutConstraint!
    
    @IBOutlet var detailButton: UIButton!
    
    weak var delegate : FiveADayCollectionViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImageView.roundCorners(corners: [.topLeft, .topRight], radius: self.shadowView.cornerRadius)
    }
    
    //MARK: My Methods
    
    func setUpCell(deal: Deal) {
        self.coverImageView.setImageWith(url: URL(string: deal.imageUrl.value!), showRetryButton: false)
        self.dealTitleLabel.text = deal.title.value
        self.dealSubTitleLabel.text =  deal.subTitle.value
        self.dealDetailLabel.text =  deal.detail.value
        self.locationLabel.text = deal.establishment.value!.title.value
        
        if let distance = deal.establishment.value?.distance {
            self.distanceLabel.isHidden = false
            self.distanceLabel.text = "\(distance.value) miles away"
        } else {
            self.distanceLabel.isHidden = true
            self.distanceLabel.text = ""
        }
 
        if UIScreen.main.bounds.size.width == 320.0 {
            self.coverImageHeight.constant = 165.0
        } else {
            let coverHeight = ((220.0 / 302.0) * self.frame.width)
            self.coverImageHeight.constant = coverHeight
        }

        self.layoutIfNeeded()
        
        if self.dealDetailLabel.isTruncated {
            self.dealDetailLabel.isHidden = true
            self.detailVerticalSpacing.constant = 8.0 + 29.0
            
            self.detailButton.isHidden = false
        } else {
            self.dealDetailLabel.isHidden = false
            self.detailVerticalSpacing.constant = 8.0
            
            self.detailButton.isHidden = true
        }
        
    }
    
    //MARK: My IBActions
    @IBAction func redeemDealButtonTapped(_ sender: UIButton) {
        self.delegate!.fiveADayCell(cell: self, redeemedButtonTapped: sender)
    }
    
    @IBAction func viewDetailButtonTapped(_ sender: UIButton) {
        self.delegate.fiveADayCell(cell: self, viewDetailButtonTapped: sender)
    }
}
