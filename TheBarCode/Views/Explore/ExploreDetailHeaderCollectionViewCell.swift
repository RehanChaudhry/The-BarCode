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

    @IBOutlet var coverImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: My Methods
    
    func setUpCell(imageName: String) {
        self.coverImageView.image = UIImage(named: imageName)
    }

}
