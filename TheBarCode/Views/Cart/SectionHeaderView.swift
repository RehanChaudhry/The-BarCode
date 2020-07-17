//
//  SectionHeaderView.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class SectionHeaderView: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet var titleLabel: UILabel!
       
       func setupHeader(title: String) {
           self.titleLabel.text = title
       }

}
