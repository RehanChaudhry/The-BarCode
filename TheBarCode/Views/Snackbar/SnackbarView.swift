//
//  SnackbarView.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Gradientable
import Reusable

enum SnackbarType: String {
    case discount = "discount", reload = "reload", canReload = "canReload"
}

enum GradientType: String {
    case green = "green", orange = "orange"
}

class SnackbarView: GradientView, NibLoadable {

    @IBOutlet var discountInfoView: UIView!
    
    @IBOutlet var discountInfoLabel: UILabel!
    
    @IBOutlet var reloadInfoView: UIView!
    @IBOutlet var reloadInfoLabel: UILabel!
    @IBOutlet var reloadTimerLabel: UILabel!
    
    @IBOutlet var creditsLeftView: UIView!
    @IBOutlet var creditsLeftLabel: UIView!

    var type: SnackbarType = .discount
    var gradientType: GradientType = .green
    
    func updateAppearanceForType(type: SnackbarType, gradientType: GradientType) {
        
        self.type = type
        
        
        if type == .discount {
            self.reloadInfoView.isHidden = true
            self.discountInfoView.isHidden = false
            self.discountInfoLabel.text = "GET 25% OFF YOUR FIRST ROUND"

        } else if type == .reload {
            self.reloadInfoView.isHidden = false
            self.discountInfoView.isHidden = true
            self.reloadInfoLabel.text = ""
        } else if type == .canReload {
            self.reloadInfoView.isHidden = false
            self.discountInfoView.isHidden = true
            self.discountInfoLabel.text = "CONGRATS YOU ARE ABLE TO RELOAD"
        }
        
        self.gradientType = gradientType
        if gradientType == .green {
            self.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
        } else if gradientType == .orange {
            
        }
    }
    
    
    
}
