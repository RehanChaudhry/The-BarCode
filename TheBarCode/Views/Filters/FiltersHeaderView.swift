//
//  FiltersHeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class FiltersHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    func setupHeader(title: String) {
        self.titleLabel.text = title.uppercased()
    }
}
