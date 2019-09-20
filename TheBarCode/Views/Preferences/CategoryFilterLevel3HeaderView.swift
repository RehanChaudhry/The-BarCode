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
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, expandButtonTapped sender: UIButton)
    func categoryFilterLevel3HeaderView(headerView: CategoryFilterLevel3HeaderView, checkboxButtonTapped sender: UIButton)
}

class CategoryFilterLevel3HeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var stackView1: UIView!
    @IBOutlet var stackView2: UIView!
    @IBOutlet var stackView3: UIView!
    
    @IBOutlet var stackViewBottomMargin: NSLayoutConstraint!
    @IBOutlet var stackViewRightMargin: NSLayoutConstraint!
    
    @IBOutlet var checkboxButton: UIButton!
    @IBOutlet var expandButton: UIButton!
    
    @IBOutlet var selectionIndicator: UIImageView!
    @IBOutlet var expandIndicator: UIImageView!

    var section: Int!
    
    weak var delegate: CategoryFilterLevel3HeaderViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
        
        self.expandIndicator.tintColor = UIColor.appGreenColor()
        
        self.titleButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.titleButton.titleLabel?.numberOfLines = 2
    }
    
    func setupForLevel3(category: Category, isExpanded: Bool) {
        
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
            
            self.expandButton.isHidden = false
            self.expandIndicator.isHidden = false
        } else {
            self.stackViewRightMargin.constant = 16.0
            self.stackViewBottomMargin.constant = 8.0
            self.stackView2.isHidden = true
            self.stackView3.isHidden = true
            
            self.expandButton.isHidden = true
            self.expandIndicator.isHidden = true
        }
        
        if isExpanded {
            self.expandIndicator.image = UIImage(named: "icon_minus")?.withRenderingMode(.alwaysTemplate)
        } else {
            self.expandIndicator.image = UIImage(named: "icon_add")?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    //MARK: My IBActions
    @IBAction func headerButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel3HeaderView(headerView: self, titleButtonTapped: sender)
    }
    
    @IBAction func checkboxButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel3HeaderView(headerView: self, checkboxButtonTapped: sender)
    }
    
    @IBAction func expandButtonTapped(sender: UIButton) {
        self.delegate.categoryFilterLevel3HeaderView(headerView: self, expandButtonTapped: sender)
    }
}
