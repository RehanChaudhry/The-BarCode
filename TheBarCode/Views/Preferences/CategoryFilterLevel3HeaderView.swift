//
//  CategoryFilterLevel3HeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CategoryFilterLevel3HeaderViewDelegate: class {
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, titleButtonTapped sender: UIButton)
}

class CategoryFilterLevel3HeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var selectionIndicator: UIImageView!

    var section: Int!
    
    weak var delegate: CategoryFilterLevel3HeaderViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        
        self.selectionIndicator.tintColor = UIColor.appBlueColor()
        self.selectionIndicator.image = self.selectionIndicator.image?.withRenderingMode(.alwaysTemplate)
    }
    
    func setupForLevel3(category: Category) {
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(category.title.value, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.selectionIndicator.isHidden = !category.isSelected.value
    }
    
    //MARK: My IBActions
    @IBAction func headerButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel3HeaderView(headerView: self, titleButtonTapped: sender)
    }
}
