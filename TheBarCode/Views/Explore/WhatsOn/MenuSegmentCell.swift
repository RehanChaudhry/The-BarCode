//
//  MenuSegmentCell.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 28/07/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import DropDown

class MenuSegmentCell: DropDownCell {
    @IBOutlet weak var segmentProductsCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
