//
//  GradientView.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Gradientable

class GradientView: UIView, Gradientable {

    @IBInspectable
    public var cornerRadius: CGFloat = 2.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
    }
    
    //MARK: My Methods
    
    func updateGradient(colors: [UIColor]?, locations: [NSNumber]?, direction: GradientableOptionsDirection) {
        let gradientOptions = GradientableOptions(colors: colors, locations: locations, direction: direction)
        self.set(options: gradientOptions)
    }
}
