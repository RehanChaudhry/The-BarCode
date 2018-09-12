//
//  CategoryCollectionViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CategoryCollectionViewCellDelegate: class {
    func categoryCell(cell: CategoryCollectionViewCell, categoryButtonTapped sender: UIButton)
}

class CategoryCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var titleButton: UIButton!
    
    weak var delegate: CategoryCollectionViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageView.layer.borderColor = UIColor.appBlueColor().cgColor
    }
    
    //MARK: My Methods
    
    func setUpCell(category: Category) {
        
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(category.title, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.imageView.image = UIImage(named: category.image)
        
        if category.isSelected {
            self.imageView.layer.borderWidth = 1.0
            self.titleButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        } else {
            self.imageView.layer.borderWidth = 0.0
            self.titleButton.setTitleColor(UIColor.white, for: .normal)
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func categoryButtonTapped(sender: UIButton) {
        self.delegate.categoryCell(cell: self, categoryButtonTapped: sender)
    }

}
