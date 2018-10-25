//
//  ExploreDetailHeaderCollectionViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 01/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ExploreDetailHeaderCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: My Methods
    
    func setUpCell(imageName: String) {
        let url = URL(string: imageName)
      //  self.coverImageView.setImageWith(url: url, showRetryButton: false)
        
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
            , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
    }

}
