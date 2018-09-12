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

class LoginIntroCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet var containerView: GradientView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func setUpCell() {
        containerView.updateGradient(colors: [UIColor.appGradientGrayStart(), UIColor.appGradientGrayEnd()], locations: nil, direction: GradientableOptionsDirection.bottom)
    }

}
