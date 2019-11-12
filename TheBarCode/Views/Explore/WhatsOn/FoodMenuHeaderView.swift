//
//  FoodMenuHeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 04/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FoodMenuHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    
    func setupHeader(title: String) {
        self.titleLabel.text = title.uppercased()
    }

}
