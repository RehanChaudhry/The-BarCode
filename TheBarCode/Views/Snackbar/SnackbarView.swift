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


protocol SnackbarViewDelegate: class {
    func snackbarView(view: SnackbarView, creditButtonTapped sender: UIButton)
    func snackbarView(view: SnackbarView, bannerButtonTapped sender: UIButton)
}

class SnackbarView: GradientView, NibLoadable {

    @IBOutlet var discountInfoView: UIView!
    
    @IBOutlet var discountInfoLabel: UILabel!
    
    @IBOutlet var reloadInfoView: UIView!
    @IBOutlet var reloadInfoLabel: UILabel!
    @IBOutlet var reloadTimerLabel: UILabel!
    
    @IBOutlet var creditsLeftView: UIView!
    @IBOutlet var creditsLeftButton: UIButton!
    
    weak var delegate: SnackbarViewDelegate!

    var type: SnackbarType = .discount
    var gradientType: GradientType = .green
    
    var loadingView: LoadingAndErrorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadingView = LoadingAndErrorView.loadFromNib()
        self.loadingView.activityIndicator.activityIndicatorViewStyle = .gray
        self.loadingView.activityIndicator.color = .black
        
        self.addSubview(self.loadingView)
        
        self.loadingView.autoPinEdgesToSuperviewEdges()
        
        
        let loadingGradientView = GradientView()
        loadingGradientView.tag = 100
        loadingGradientView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
        self.loadingView.insertSubview(loadingGradientView, at: 0)
        loadingGradientView.autoPinEdgesToSuperviewEdges()
        
    }
    
    //MARK: My Methods
    func updateAppearanceForType(type: SnackbarType, gradientType: GradientType) {
       
        self.type = type
        
        let user = Utility.shared.getCurrentUser()
        self.creditsLeftButton.setTitle("\(user!.credit)", for: .normal)
        
        if type == .discount {
            self.reloadInfoView.isHidden = true
            self.discountInfoView.isHidden = false
            self.discountInfoLabel.text = "GET 25% OFF YOUR FIRST ROUND"

        } else if type == .reload {
            self.reloadInfoView.isHidden = false
            self.discountInfoView.isHidden = true
            self.reloadInfoLabel.text = "RELOAD IN "
        } else if type == .congrates {
            self.reloadInfoView.isHidden = true
            self.discountInfoView.isHidden = false
            self.discountInfoLabel.text = "CONGRATS YOU ARE ABLE TO RELOAD"
        }
        
        self.gradientType = gradientType
        if gradientType == .green {
            self.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
            
            let loadingGradientView = self.loadingView.viewWithTag(100) as! GradientView
            loadingGradientView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
            
        } else if gradientType == .orange {
            self.updateGradient(colors: [UIColor.appSnackBarOrangeColor(), UIColor.appSnackBarRedColor()], locations: nil, direction: GradientableOptionsDirection.right)
            
            let loadingGradientView = self.loadingView.viewWithTag(100) as! GradientView
            loadingGradientView.updateGradient(colors: [UIColor.appSnackBarOrangeColor(), UIColor.appSnackBarRedColor()], locations: nil, direction: GradientableOptionsDirection.right)
        }
    }
    
    func showLoading() {
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
    }
    
    func hideLoading() {
        self.loadingView.isHidden = true
        self.loadingView.showNothing()
    }
    
    func showError(msg: String) {
        self.loadingView.showErrorViewWithRetry(errorMessage: msg, reloadMessage: "")
    }
    
    func updateTimer(remainingSeconds: Int) {
        self.reloadTimerLabel.text = "\(Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds)))"
    }
    
    //MARK: My IBActions
    
    @IBAction func creditButtonTapped(sender: UIButton) {
        self.delegate.snackbarView(view: self, creditButtonTapped: sender)
    }
    
    @IBAction func bannerButtonTapped(_ sender: UIButton) {
        self.delegate.snackbarView(view: self, bannerButtonTapped: sender)
    }
    
}

