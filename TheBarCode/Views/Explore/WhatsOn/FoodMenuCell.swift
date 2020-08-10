//
//  FoodMenuCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FoodMenuCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var detailLabelTop: NSLayoutConstraint!
    
    @IBOutlet var priceContainer: UIView!
    @IBOutlet var priceContainerHeight: NSLayoutConstraint!
    @IBOutlet var priceContainerTop: NSLayoutConstraint!
    
    @IBOutlet var cartIconImageView: UIImageView!
    
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
        
        self.cartIconImageView.image = self.cartIconImageView.image?.withRenderingMode(.alwaysTemplate)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForDrink(drink: Drink) {
        
        self.titleLabel.attributedText = drink.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = drink.detail.value.html2Attributed(isTitle: false)
        
        if drink.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 0.0
        }
        
        let price = Double(drink.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "£ " + priceString
        
        if price <= 0.0 {
            self.priceContainerTop.constant = 0.0
            self.priceContainerHeight.constant = 0.0
            
            self.priceContainer.isHidden = true
        } else {
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.priceContainer.isHidden = false
        }
        
    }
    
    func setupCellForFood(food: Food) {
        
        self.titleLabel.attributedText = food.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = food.detail.value.html2Attributed(isTitle: false)
        
        if food.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 0.0
        }
        
        let price = Double(food.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "£ " + priceString
        
        if price <= 0.0 {
            self.priceContainerTop.constant = 0.0
            self.priceContainerHeight.constant = 0.0
            
            self.priceContainer.isHidden = true
        } else {
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.priceContainer.isHidden = false
        }
    }
}
