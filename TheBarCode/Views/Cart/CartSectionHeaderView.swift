//
//  CartSectionHeaderView.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class CartSectionHeaderView: UITableViewHeaderFooterView, NibReusable {
 
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectionView: UIView!
    
    func setupHeader(title: String) {
        self.titleLabel.text = title
        
        self.selectionView.backgroundColor = UIColor.appCartUnSelectedColor()
        
        self.selectionView.layer.cornerRadius = 8
        self.selectionView.layer.borderWidth = 2
        self.selectionView.layer.borderColor = UIColor.appCartUnSelectedColor().cgColor
        
    }

    @IBAction func selectionButtonTapped(_ sender: Any) {
        
        self.selectionView.backgroundColor = UIColor.appBlueColor()

        
    }
}
