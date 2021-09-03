//
//  CartSectionHeaderView.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol CartSectionHeaderViewDelegate : class {
    func cartSectionHeaderView(view: CartSectionHeaderView, selectedBarId: String, tag: Int)
}

class CartSectionHeaderView: UITableViewHeaderFooterView, NibReusable {
 
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectionView: UIView!
    @IBOutlet weak var selectionButton: UIButton!
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var infoLabelBottom: NSLayoutConstraint!
    
    weak var delegate: CartSectionHeaderViewDelegate!
    var barId: String!
    var buttonToggle = true
    var cartID = ""
    func setupHeader(title: String, isSelected: Bool, isVenueClosed: Bool, cartType: String) {
//        let suffix = cartType != "" ? " - " : ""
//        self.titleLabel.text = title + suffix + cartType.replacingOccurrences(of: "_", with: " ").capitalized
        
        if cartType == "dine_in_collection" {
            
            self.titleLabel.text = "Table Service"
        }
        else{
            
            self.titleLabel.text = "Take Away/Delivery"
        }
        
        
        self.selectionButton.layer.cornerRadius = 8
        self.selectionButton.layer.borderWidth = 2
        self.selectionButton.layer.borderColor = UIColor.appCartUnSelectedColor().cgColor
        
        if isVenueClosed {
            self.infoLabelBottom.constant = 8.0
            self.infoLabel.text = "Venue is closed"
        } else {
            self.infoLabelBottom.constant = 0.0
            self.infoLabel.text = ""
        }
        
    }

    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        
//        self.selectionView.backgroundColor = UIColor.appBlueColor()
        self.delegate.cartSectionHeaderView(view: self, selectedBarId: self.cartID, tag: sender.tag)
        self.selectionButton.backgroundColor = self.buttonToggle ? UIColor.appBlueColor() : UIColor.appCartUnSelectedColor()
        self.buttonToggle = !self.buttonToggle
    }
    
    func setButtonColor(state: Bool) {
        self.selectionButton.backgroundColor = state ? UIColor.appBlueColor() : UIColor.appCartUnSelectedColor()
    }
    
    @IBAction func selectionBtnAction(_ sender: UIButton) {
        
    }
}
