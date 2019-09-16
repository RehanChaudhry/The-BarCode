//
//  ExploreImageCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 30/05/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import FSPagerView

class ExploreImageCell: FSPagerViewCell {

    @IBOutlet var coverImageView: AsyncImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setUpCell(imageName: String) {
        let url = URL(string: imageName)
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
            , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
    }
}
