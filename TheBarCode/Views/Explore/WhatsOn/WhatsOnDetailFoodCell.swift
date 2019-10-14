//
//  WhatsOnDetailFoodCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol WhatsOnDetailFoodCellDelegate: class {
    func whatsOnDetailFoodCell(cell: WhatsOnDetailFoodCell, directionButtonTapped sender: UIButton)
}

class WhatsOnDetailFoodCell: UITableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var barNameButton: UIButton!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    weak var delegate : WhatsOnDetailFoodCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func setupDrink(drink: Drink, bar: Bar) {
        
        self.typeLabel.text = drink.categoryName.value
        self.detailLabel.text = drink.detail.value
        
        let price = Double(drink.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.infoLabel.text = "Price: £ " + priceString
        self.infoLabel.isHidden = price == 0.0
        
        self.barNameButton.setTitle(bar.title.value, for: .normal)
        
        self.distanceLabel.text = Utility.shared.getformattedDistance(distance: bar.distance.value)
        
    }
    
    func setupFood(food: Food, bar: Bar) {
        
        self.typeLabel.text = food.categoryName.value
        self.infoLabel.text = "Price: £ " + food.price.value
        self.detailLabel.text = food.detail.value
        
        let price = Double(food.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.infoLabel.text = "Price: £ " + priceString
        self.infoLabel.isHidden = price == 0.0
        
        self.barNameButton.setTitle(bar.title.value, for: .normal)
        
        self.distanceLabel.text = Utility.shared.getformattedDistance(distance: bar.distance.value)
    }
    
    //MARK: My IBActions
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        self.delegate.whatsOnDetailFoodCell(cell: self, directionButtonTapped: sender)
    }
    
}
