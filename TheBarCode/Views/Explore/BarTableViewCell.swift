//
//  BarTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol BarTableViewCellDelegare: class {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton)
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton)

}

class BarTableViewCell: ExploreBaseTableViewCell, NibReusable {

    @IBOutlet var favouriteButton: UIButton!
    
    weak var delegate : BarTableViewCellDelegare!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.favouriteButton.tintColor = UIColor.appLightGrayColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func setUpCell(bar: Bar) {
        super.setUpCell(explore: bar)
       self.favouriteButton.tintColor = bar.isUserFavourite.value ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
    }
    
    //MARK: IBAction
    
    @IBAction func favouriteButtonTapped(_ sender: UIButton) {
        self.delegate!.barTableViewCell(cell: self, favouriteButton: sender)
    }
    
    @IBAction func distanceButtonTapped(_ sender: UIButton) {
        self.delegate.barTableViewCell(cell: self, distanceButtonTapped: sender)
    }
}


