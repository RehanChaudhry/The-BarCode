//
//  CategoryFilterLevel4Cell.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CategoryFilterLevel4CellDelegate: class {
    func categoryFilterLevel4Cell(cell: CategoryFilterLevel4Cell, titleButtonTapped sender: UIButton)
}

class CategoryFilterLevel4Cell: UITableViewCell, NibReusable {
    
    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var selectionIndicator: UIImageView!
    
    @IBOutlet var checkboxButton: UIButton!
    
    @IBOutlet var stackView1: UIView!
    @IBOutlet var stackView2: UIView!
    @IBOutlet var stackView3: UIView!
    
    @IBOutlet var stackViewBottomMargin: NSLayoutConstraint!
    @IBOutlet var stackViewRightMargin: NSLayoutConstraint!
    
    weak var delegate: CategoryFilterLevel4CellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.checkboxButton.layer.borderWidth = 1.0
        self.checkboxButton.layer.cornerRadius = 2.0
        self.checkboxButton.layer.borderColor = UIColor.appBlueColor().cgColor
        
        self.stackView1.layer.borderWidth = 1.0
        self.stackView1.layer.cornerRadius = 5.0
        self.stackView1.layer.borderColor = UIColor.white.cgColor
        
        self.stackView2.layer.borderWidth = 1.0
        self.stackView2.layer.cornerRadius = 5.0
        self.stackView2.layer.borderColor = UIColor.white.cgColor
        
        self.stackView3.layer.borderWidth = 1.0
        self.stackView3.layer.cornerRadius = 5.0
        self.stackView3.layer.borderColor = UIColor.white.cgColor
        
        self.selectionIndicator.tintColor = UIColor.white
        self.selectionIndicator.image = self.selectionIndicator.image?.withRenderingMode(.alwaysTemplate)
        
        self.titleButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleButton.titleLabel?.numberOfLines = 2
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
        
        if category.isSelected.value {
            self.selectionIndicator.isHidden = false
            
            self.stackView1.layer.borderColor = UIColor.appBlueColor().cgColor
            self.stackView2.layer.borderColor = UIColor.appBlueColor().cgColor
            self.stackView3.layer.borderColor = UIColor.appBlueColor().cgColor
            
            self.checkboxButton.layer.borderColor = UIColor.appBlueColor().cgColor
            self.checkboxButton.backgroundColor = UIColor.appBlueColor()
            
        } else {
            self.selectionIndicator.isHidden = true
            
            self.stackView1.layer.borderColor = UIColor.white.cgColor
            self.stackView2.layer.borderColor = UIColor.white.cgColor
            self.stackView3.layer.borderColor = UIColor.white.cgColor
            
            self.checkboxButton.layer.borderColor = UIColor.white.cgColor
            self.checkboxButton.backgroundColor = UIColor.clear
        }
        
        if category.hasChildren.value {
            self.stackViewRightMargin.constant = 16.0 + 6.0
            self.stackViewBottomMargin.constant = 16.0
            self.stackView2.isHidden = false
            self.stackView3.isHidden = false
        } else {
            self.stackViewRightMargin.constant = 16.0
            self.stackViewBottomMargin.constant = 8.0
            self.stackView2.isHidden = true
            self.stackView3.isHidden = true
        }
    }
    
    //MARK: My IBActions
    @IBAction func titleButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel4Cell(cell: self, titleButtonTapped: sender)
    }
    
    @IBAction func checkboxButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel4Cell(cell: self, titleButtonTapped: sender)
    }
}
