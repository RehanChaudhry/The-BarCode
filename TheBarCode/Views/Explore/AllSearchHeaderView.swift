//
//  AllSearchHeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class AllSearchHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clear
    }

    func setup(title: String) {
        self.titleLabel.text = title.uppercased()
    }
}
