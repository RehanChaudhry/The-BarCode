//
//  LoginIntroCollectionViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import Gradientable
import FSPagerView

class LoginIntroCollectionViewCell: FSPagerViewCell, NibReusable {

    @IBOutlet var containerView: GradientView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var coverImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setUpCell(option: IntroOption) {
        self.titleLabel.text = option.title
        self.detailLabel.text = option.detail
        self.coverImage.image = UIImage(named: option.image)
        
        containerView.updateGradient(colors: [UIColor.appGradientGrayStart(), UIColor.appGradientGrayEnd()], locations: nil, direction: GradientableOptionsDirection.bottom)
        
    }

}
