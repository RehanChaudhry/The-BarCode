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
    case discount = "discount", reload = "reload", congrates = "congrates"
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
    @IBOutlet var creditsLeftLabel: UILabel!

    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    var type: SnackbarType = .discount
    var gradientType: GradientType = .green
    
    var timer = Timer()
    var seconds = 0
    
    func updateAppearanceForType(type: SnackbarType, gradientType: GradientType) {
       
        self.activitySpinner.isHidden = true

        self.type = type
        
        let user = Utility.shared.getCurrentUser()
        self.creditsLeftLabel.text = "\(user!.credit)"
        
        self.seconds = ReedeemInfoManager.shared.redeemInfo?.remainingSeconds! ?? 0
        
        if self.seconds > 0 {
            runTimer()
        }
        
        if type == .discount {
            self.reloadInfoView.isHidden = true
            self.discountInfoView.isHidden = false
            self.discountInfoLabel.text = "GET 25% OFF YOUR FIRST ROUND"

        } else if type == .reload {
            self.reloadInfoView.isHidden = false
            self.discountInfoView.isHidden = true
            self.reloadInfoLabel.text = "RELOAD IN "
        } else if type == .congrates {
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
    
    func loadingSpinner() {
        self.activitySpinner.isHidden = false
        self.activitySpinner.startAnimating()
        self.reloadInfoView.isHidden = true
        self.discountInfoView.isHidden = true
    }
}


extension SnackbarView {
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(SnackbarView.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        seconds = ReedeemInfoManager.shared.updateRedeemInfo()
        if seconds < 0 {
            timer.invalidate()
            ReedeemInfoManager.shared.isTimerRunning = false
            self.updateAppearanceForType(type: .congrates, gradientType: .orange)
            return
        }
        let timerString = Utility.shared.timeString(time: TimeInterval(seconds))
        self.reloadTimerLabel.text = timerString
    }
}
