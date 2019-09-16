//
//  CategoryFilterLevel2Cell.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CategoryFilterLevel2CellDelegate: class {
    func categoryFilterLevel2Cell(cell: CategoryFilterLevel2Cell, titleButtonTapped sender: UIButton)
}

class CategoryFilterLevel2Cell: UITableViewCell, NibReusable {

    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var selectionIndicator: UIImageView!
    
    weak var delegate: CategoryFilterLevel2CellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.selectionIndicator.tintColor = UIColor.appBlueColor()
        self.selectionIndicator.image = self.selectionIndicator.image?.withRenderingMode(.alwaysTemplate)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(category: Category) {
        
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(category.title.value, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.selectionIndicator.isHidden = !category.isSelected.value
        
        if category.hasChildren.value {
            self.accessoryType = .disclosureIndicator
        } else {
            self.accessoryType = .none
        }
        
    }
    
    //MARK: My IBActions
    @IBAction func titleButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel2Cell(cell: self, titleButtonTapped: sender)
    }
    
}
