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
    
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForDrink(drink: Drink, topPadding: Bool = true) {
        
//        self.setupTitle(title: drink.name.value)
//        self.setupDetail(details: drink.detail.value)
        
        self.titleLabel.attributedText = drink.name.value.html2Attributed
        self.detailLabel.attributedText = drink.detail.value.html2Attributed
        
        let price = Double(drink.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "   £ " + priceString + "   "
        self.priceLabel.isHidden = price == 0.0
        
//        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
    
    func setupCellForFood(food: Food, topPadding: Bool = true) {
        
//        self.setupTitle(title: food.name.value)
//        self.setupDetail(details: food.detail.value)

        self.titleLabel.attributedText = food.name.value.html2Attributed
        self.detailLabel.attributedText = food.detail.value.html2Attributed
        
        let price = Double(food.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "   £ " + priceString + "   "
        self.priceLabel.isHidden = price == 0.0
        
//        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
}
