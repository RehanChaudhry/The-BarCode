//
//  ExploreDetailHeaderCollectionViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 01/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView

class ExploreDetailHeaderCollectionViewCell: FSPagerViewCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: My Methods
    
    func setUpCell(imageName: String) {
        let url = URL(string: imageName)
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
            , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.priceLabel.isHidden = true
    }
    
    
    func setUpCell(imageName: String, deal: Deal, currencySymbol: String) {
        
        let url = URL(string: imageName)
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
                   , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        
        if deal.isVoucher.value {
            let price = deal.voucherAmount.value ?? 0.0
            let priceString = String(format: "%.2f", price)
            self.priceLabel.text = "   \(currencySymbol) " + priceString + "   "
            self.priceLabel.isHidden = price == 0.0
        } else {
             self.priceLabel.isHidden = true
        }
        
    }

}
