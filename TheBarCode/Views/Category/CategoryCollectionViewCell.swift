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

    @IBOutlet var stackImageView1: AsyncImageView!
    @IBOutlet var stackImageView2: AsyncImageView!
    
    @IBOutlet var imageView: AsyncImageView!
    
    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var rightMargin: NSLayoutConstraint!
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    weak var delegate: CategoryCollectionViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.stackImageView1.layer.borderWidth = 1.0
        self.stackImageView2.layer.borderWidth = 1.0
        self.imageView.layer.borderWidth = 1.0
    }
    
    //MARK: My Methods
    
    func setUpCell(category: Category) {
        
        self.titleButton.titleLabel?.textAlignment = .center

        UIView.performWithoutAnimation {
            self.titleButton.setTitle(category.title.value, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        let url = URL(string: category.image.value)
        self.imageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "square_placeholder"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.imageView.backgroundColor = UIColor.appDarkGrayColor()
        
        if category.isSelected.value {
            self.stackImageView1.layer.borderColor = UIColor.appBlueColor().cgColor
            self.stackImageView2.layer.borderColor = UIColor.appBlueColor().cgColor
            self.imageView.layer.borderColor = UIColor.appBlueColor().cgColor
            
            self.titleButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        } else {
            self.stackImageView1.layer.borderColor = UIColor.white.cgColor
            self.stackImageView2.layer.borderColor = UIColor.white.cgColor
            self.imageView.layer.borderColor = UIColor.white.cgColor
            
            self.titleButton.setTitleColor(UIColor.white, for: .normal)
        }
        
        if category.hasChildren.value {
            self.stackImageView1.isHidden = false
            self.stackImageView2.isHidden = false
            
            self.bottomMargin.constant = 9.0
            self.rightMargin.constant = 9.0
            
        } else {
            self.stackImageView1.isHidden = true
            self.stackImageView2.isHidden = true
            
            self.rightMargin.constant = 0.0
            self.bottomMargin.constant = 0.0
        }
        
        
        
        self.stackImageView1.backgroundColor = UIColor.clear
        self.stackImageView2.backgroundColor = UIColor.clear
        self.imageView.backgroundColor = UIColor.clear
    }
    
    //MARK: My IBActions
    
    @IBAction func categoryButtonTapped(sender: UIButton) {
        self.delegate.categoryCell(cell: self, categoryButtonTapped: sender)
    }

}
