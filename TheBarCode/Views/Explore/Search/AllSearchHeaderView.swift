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

    @IBOutlet var strokeView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clear
    }

    func setup(strokeColor: UIColor?) {
        if let strokeColor = strokeColor {
            self.strokeView.backgroundColor = strokeColor
        } else {
            self.strokeView.backgroundColor = UIColor.clear
        }
    }
}
