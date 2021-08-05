//
//  SimilarProductsCell.swift
//  TheBarCode
//
//  Created by Zeeshan on 27/07/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class SimilarProductsCell: UICollectionViewCell, NibReusable {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var productImage: AsyncImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
