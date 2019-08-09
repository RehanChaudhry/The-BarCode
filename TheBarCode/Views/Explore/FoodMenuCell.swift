//
//  FoodMenuCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import Atributika

class FoodMenuCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
                
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
        self.typeLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForDrink(drink: Drink, topPadding: Bool = true) {
        
        self.setupTitle(title: drink.name.value)
        self.setupDetail(details: drink.detail.value)
        
        self.typeLabel.text = drink.categoryName.value
        self.priceLabel.text = "   £ " + drink.price.value + "   "
        
        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
    
    func setupCellForFood(food: Food, topPadding: Bool = true) {
        
        self.setupTitle(title: food.name.value)
        self.setupDetail(details: food.detail.value)
        
        self.typeLabel.text = food.categoryName.value
        self.priceLabel.text = "   £ " + food.price.value + "   "
        
        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
    
    func setupTitle(title: String) {
        let h1 = Style("h1").font(UIFont.appRegularFontOf(size: 28.0))
        let h2 = Style("h2").font(UIFont.appRegularFontOf(size: 22.0))
        let h3 = Style("h3").font(UIFont.appRegularFontOf(size: 18.0))
        
        let b = Style("b").font(UIFont.appBoldFontOf(size: 14.0))
        let u = Style("u").underlineStyle(.styleSingle)
        let i = Style("i").font(UIFont.italicSystemFont(ofSize: 14.0))
        
        let all = Style.foregroundColor(.white)
        
        self.titleLabel.attributedText = title
            .style(tags: h1, h2, h3, b, u, i)
            .styleAll(all)
            .styleAll(Style.font(UIFont.boldSystemFont(ofSize: 14.0)))
            .attributedString
    }
    
    func setupDetail(details: String) {
        let h1 = Style("h1").font(UIFont.appRegularFontOf(size: 26.0))
        let h2 = Style("h2").font(UIFont.appRegularFontOf(size: 20.0))
        let h3 = Style("h3").font(UIFont.appRegularFontOf(size: 16.0))
        
        let b = Style("b").font(UIFont.appBoldFontOf(size: 14.0))
        let u = Style("u").underlineStyle(.styleSingle)
        let i = Style("i").font(UIFont.italicSystemFont(ofSize: 14.0))
        
        let all = Style.foregroundColor(.white)
        
        self.detailLabel.attributedText = details
            .style(tags: h1, h2, h3, b, u, i)
            .styleAll(all)
            .styleAll(Style.font(UIFont.appRegularFontOf(size: 12.0)))
            .attributedString
    }
}
