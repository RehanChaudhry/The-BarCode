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
        
        self.setupTitle(title: drink.name.value)
        self.setupDetail(details: drink.detail.value)
        
        let price = Double(drink.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "   £ " + priceString + "   "
        
        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
    
    func setupCellForFood(food: Food, topPadding: Bool = true) {
        
        self.setupTitle(title: food.name.value)
        self.setupDetail(details: food.detail.value)
//        self.titleLabel.attributedText = food.name.value.html2Attributed
//        self.detailLabel.attributedText = food.detail.value.html2Attributed
        
        let price = Double(food.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "   £ " + priceString + "   "
        
        self.topPadding.constant = topPadding ? 8.0 : 0.0
    }
    
    func setupTitle(title: String) {
        let h1 = Style("h1").font(UIFont.appRegularFontOf(size: 22.0))
        let h2 = Style("h2").font(UIFont.appRegularFontOf(size: 22.0))
        let h3 = Style("h3").font(UIFont.appRegularFontOf(size: 20.0))
        let h4 = Style("h3").font(UIFont.appRegularFontOf(size: 18.0))
        
        let b = Style("b").font(UIFont.appBoldFontOf(size: 14.0))
        let u = Style("u").underlineStyle(.styleSingle)
        let i = Style("i").font(UIFont.italicSystemFont(ofSize: 14.0))
        
        let all = Style.foregroundColor(.white)
        
        self.titleLabel.attributedText = title
            .style(tags: h1, h2, h3, h4, b, u, i)
            .styleAll(all)
            .styleAll(Style.font(UIFont.boldSystemFont(ofSize: 14.0)))
            .attributedString
    }
    
    func setupDetail(details: String) {
        let h1 = Style("h1").font(UIFont.appRegularFontOf(size: 22.0))
        let h2 = Style("h2").font(UIFont.appRegularFontOf(size: 22.0))
        let h3 = Style("h3").font(UIFont.appRegularFontOf(size: 20.0))
        let h4 = Style("h3").font(UIFont.appRegularFontOf(size: 18.0))
        
        let b = Style("b").font(UIFont.appBoldFontOf(size: 14.0))
        let u = Style("u").underlineStyle(.styleSingle)
        let i = Style("i").font(UIFont.italicSystemFont(ofSize: 14.0))
        
        let all = Style.foregroundColor(.white)
        
        self.detailLabel.attributedText = details
            .style(tags: h1, h2, h3, h4, b, u, i)
            .styleAll(all)
            .styleAll(Style.font(UIFont.appRegularFontOf(size: 12.0)))
            .attributedString
    }
}

extension String {
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            print("error: ", error)
            return nil
        }
    }
}
