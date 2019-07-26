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
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
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
    
    func setupCellForDrink(drink: Drink) {
        self.titleLabel.text = drink.name.value
        self.detailLabel.text = drink.detail.value
        self.typeLabel.text = drink.categoryName.value
        self.priceLabel.text = "   £ " + drink.price.value + "   "
    }
    
    func setupCellForFood(food: Food) {
        self.titleLabel.text = food.name.value
        self.detailLabel.text = food.detail.value
        self.typeLabel.text = food.categoryName.value
        self.priceLabel.text = "   £ " + food.price.value + "   "
    }
}
