//
//  GradientButton.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Gradientable

class GradientButton: GradientableButton {

    @IBInspectable
    public var cornerRadius: CGFloat = 2.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }
    
    var startColor: UIColor = UIColor.appGreenColor()
    var endColor: UIColor = UIColor.appBlueColor()
    var locations: [NSNumber]?
    var directions: GradientableOptionsDirection = .right
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateGradient(colors: [self.startColor, self.endColor], locations: self.locations, direction: directions)
    }
    
    //MARK: My Methods
    
    func updateGradient(colors: [UIColor]?, locations: [NSNumber]?, direction: GradientableOptionsDirection) {
        let gradientOptions = GradientableOptions(colors: colors, locations: locations, direction: direction)
        self.set(options: gradientOptions)
        
        if let startColor = colors?.first {
            self.startColor = startColor
        }
        
        if let endColor = colors?.last {
            self.endColor = endColor
        }
        
        if let locations = locations {
            self.locations = locations
        }
        
        self.directions = direction
    }

}
