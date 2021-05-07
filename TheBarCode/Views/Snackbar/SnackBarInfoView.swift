//
//  SnackBarInfoView.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 11/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Gradientable
import Reusable
import FirebaseAnalytics

enum SnackBarInfoViewType: String {
    case discount = "discount", reload = "reload", congrates = "congrates"
}

protocol SnackBarInfoViewDelegate: class {
    func snackBarInfoView(snackBar: SnackBarInfoView, creditsButtonTapped sender: UIButton)
    func snackBarInfoView(snackBar: SnackBarInfoView, savingsButtonTapped sender: UIButton)
    func snackBarInfoView(snackBar: SnackBarInfoView, actionButtonTapped sender: UIButton)
}

class SnackBarInfoView: UIView, NibLoadable {

    @IBOutlet var contentContainer: UIView!
    
    @IBOutlet var backgroundView: GradientView!

    @IBOutlet var actionButton: UIButton!
    
    @IBOutlet var creditsButton: UIButton!
    @IBOutlet var savingsButton: UIButton!
    
    var loadingView: LoadingAndErrorView!
    
    weak var delegate: SnackBarInfoViewDelegate?
    
    var type: SnackBarInfoViewType = .discount {
        didSet {
            self.setupBackgroundColor()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loadingView = LoadingAndErrorView.loadFromNib()
        self.loadingView.backgroundColor = UIColor.clear
        self.loadingView.activityIndicator.activityIndicatorViewStyle = .gray
        self.loadingView.activityIndicator.color = .black
        
        self.addSubview(self.loadingView)
        
        self.loadingView.autoPinEdgesToSuperviewEdges()
        
        self.actionButton.titleLabel?.numberOfLines = 0
        self.actionButton.titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    //MARK: My Methods
    func setUpSavings(totalSavings: Double, currencySymbol: String) {
        let savings = totalSavings >= 100 ? "99+" : String(format: "%.2f", totalSavings)
        
        UIView.performWithoutAnimation {
            self.savingsButton.setTitle("\(currencySymbol) \(savings)", for: .normal)
            self.savingsButton.layoutIfNeeded()
        }
    }
    
    func updateSnackbarType(type: SnackBarInfoViewType) {
        
        self.type = type
        
        let user = Utility.shared.getCurrentUser()
        let credit = user!.credit >= 100 ? "99+" : "\(user!.credit)"
        
        UIView.performWithoutAnimation {
            self.creditsButton.setTitle(credit, for: .normal)
            self.creditsButton.layoutIfNeeded()
        }
        
        switch type {
        case .congrates:
            UIView.performWithoutAnimation {
                self.actionButton.setTitleColor(UIColor.white, for: .normal)
                self.actionButton.contentHorizontalAlignment = .center
                self.actionButton.titleLabel?.textAlignment = .center
                self.actionButton.setTitle("CONGRATS YOU ARE ABLE TO RELOAD", for: .normal)
                self.actionButton.layoutIfNeeded()
            }
        case .discount:
            UIView.performWithoutAnimation {
                self.actionButton.setTitleColor(UIColor.black, for: .normal)
                self.actionButton.contentHorizontalAlignment = .left
                self.actionButton.titleLabel?.textAlignment = .left
                self.actionButton.setTitle("RELOAD IN: 07:00:00:00", for: .normal)
                self.actionButton.layoutIfNeeded()
            }
        case .reload:
            UIView.performWithoutAnimation {
                self.actionButton.setTitleColor(UIColor.black, for: .normal)
                self.actionButton.contentHorizontalAlignment = .left
                self.actionButton.titleLabel?.textAlignment = .left
                self.actionButton.setTitle("RELOAD IN: ", for: .normal)
                self.actionButton.layoutIfNeeded()
            }
        }
    }
    
    func setupBackgroundColor() {
        switch self.type {
        case .congrates:
            self.backgroundView.updateGradient(colors: [UIColor.appSnackBarOrangeColor(), UIColor.appSnackBarRedColor()], locations: nil, direction: GradientableOptionsDirection.right)
        default:
            self.backgroundView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: GradientableOptionsDirection.right)
        }
    }
    
    func showLoading() {
        self.contentContainer.isHidden = true
        self.loadingView.isHidden = false
        self.loadingView.showLoading()
    }
    
    func hideLoading() {
        self.contentContainer.isHidden = false
        self.loadingView.isHidden = true
        self.loadingView.showNothing()
    }
    
    func showError(msg: String) {
        self.loadingView.showErrorViewWithRetry(errorMessage: msg, reloadMessage: "")
    }
    
    func updateTimer(remainingSeconds: Int) {
        UIView.performWithoutAnimation {
            let remainingTime = "\(Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds)))"
            self.actionButton.setTitle("RELOAD IN: " + remainingTime, for: .normal)
            self.actionButton.layoutIfNeeded()
        }
    }
    
    //MARK: My IBActions
    @IBAction func creditsButtonTapped(sender: UIButton) {
        Analytics.logEvent(creditsClick, parameters: nil)
        self.delegate?.snackBarInfoView(snackBar: self, creditsButtonTapped: sender)
    }
    
    @IBAction func savingsButtonTapped(sender: UIButton) {
        Analytics.logEvent(savingsClick, parameters: nil)
        self.delegate?.snackBarInfoView(snackBar: self, savingsButtonTapped: sender)
    }
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        Analytics.logEvent(bannerClick, parameters: nil)
        self.delegate?.snackBarInfoView(snackBar: self, actionButtonTapped: sender)
    }
}
