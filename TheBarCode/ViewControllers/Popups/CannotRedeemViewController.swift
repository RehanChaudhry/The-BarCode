//
//  CannotRedeemViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 18/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

enum CustomAlertType: String {
    case normal,
    credit
}

protocol CannotRedeemViewControllerDelegate: class {
    func cannotRedeemController(controller: CannotRedeemViewController, okButtonTapped sender: UIButton)
}

class CannotRedeemViewController: UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reloadTimerLabel: UILabel!
    
    @IBOutlet var actionButton: GradientButton!
    
    @IBOutlet var mainViewHeightConstraint: NSLayoutConstraint!
    
    var messageText: String = ""
    var titleText: String = ""
    
    var reloadTimer: Timer?
    var redeemInfo: RedeemInfo?
    
    weak var delegate: CannotRedeemViewControllerDelegate?
    
    var alertType = CustomAlertType.normal
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.messageLabel.text = messageText
        self.titleLabel.text = titleText
        
        let heightOfMessage = messageText.heightWithConstrainedWidth(width: (self.view.frame.width - 80), font: UIFont.appRegularFontOf(size: 14.0))
        
        if alertType == .credit {
            actionButton.setTitle("Invite Friends & Get Credits", for: .normal)
        }
        
        //as timer not to show
        self.mainViewHeightConstraint.constant = heightOfMessage + 184.0
        self.reloadTimerLabel.text = ""
        
       /* if let redemInfo = self.redeemInfo, redemInfo.remainingSeconds > 0 {
            self.mainViewHeightConstraint.constant = heightOfMessage + 217.0
            self.reloadTimerLabel.text = ""
//            startReloadTimer()
        } else {
            self.reloadTimerLabel.text = ""
            self.mainViewHeightConstraint.constant = heightOfMessage + 184.0
        }*/
    }
    
    deinit {
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
    }

    //MARK: My Methods
    
    func startReloadTimer() {
        
        self.reloadTimer?.invalidate()
        self.reloadTimer = nil
        self.reloadTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [unowned self] (sender) in
            self.updateReloadTimer(sender: sender)
        })
    }
    
    func updateReloadTimer(sender: Timer) {
        
        guard let redeemInfo = self.redeemInfo else {
            debugPrint("Redeem info not available to update timer")
            return
        }
        
        if redeemInfo.remainingSeconds > 0 {
            self.redeemInfo!.remainingSeconds -= 1
            self.updateTimer(remainingSeconds: self.redeemInfo!.remainingSeconds)
        } else {
            self.reloadTimer?.invalidate()
            self.hideTimer()
        }
        
    }
    
    func updateTimer(remainingSeconds: Int) {
        self.reloadTimerLabel.text = "\(Utility.shared.getFormattedRemainingTime(time: TimeInterval(remainingSeconds)))"
    }
    
    func hideTimer() {
        self.reloadTimerLabel.text = ""
    }
    
    //MARK: IBActions
    @IBAction func okButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.cannotRedeemController(controller: self, okButtonTapped: sender)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedStringKey.font: font], context: nil)
        return boundingBox.height
    }
}


