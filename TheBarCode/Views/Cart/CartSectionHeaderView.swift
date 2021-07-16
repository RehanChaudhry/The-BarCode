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
    func cartSectionHeaderView(view: CartSectionHeaderView, selectedBarId: String)
}

class CartSectionHeaderView: UITableViewHeaderFooterView, NibReusable {
 
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var infoLabelBottom: NSLayoutConstraint!
    
    weak var delegate: CartSectionHeaderViewDelegate!
    var barId: String!
    
    func setupHeader(title: String, isSelected: Bool, isVenueClosed: Bool, cartType: String) {
        self.titleLabel.text = title + " - " + cartType.replacingOccurrences(of: "_", with: " ").capitalized
        
        self.selectionView.backgroundColor = isSelected ? UIColor.appBlueColor() : UIColor.appCartUnSelectedColor()
        
        self.selectionView.layer.cornerRadius = 8
        self.selectionView.layer.borderWidth = 2
        self.selectionView.layer.borderColor = UIColor.appCartUnSelectedColor().cgColor
        
        if isVenueClosed {
            self.infoLabelBottom.constant = 8.0
            self.infoLabel.text = "Venue is closed"
        } else {
            self.infoLabelBottom.constant = 0.0
            self.infoLabel.text = ""
        }
        
    }

    @IBAction func selectionButtonTapped(_ sender: UIButton) {
        
        self.selectionView.backgroundColor = UIColor.appBlueColor()
        self.delegate.cartSectionHeaderView(view: self, selectedBarId: self.barId)
        
    }
}
