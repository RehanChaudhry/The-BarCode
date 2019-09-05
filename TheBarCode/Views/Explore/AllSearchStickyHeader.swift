//
//  AllSearchStickyHeader.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class AllSearchStickyHeader: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var strokeView: UIView!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setup(strokeColor: UIColor) {
        self.strokeView.backgroundColor = strokeColor
    }

}
