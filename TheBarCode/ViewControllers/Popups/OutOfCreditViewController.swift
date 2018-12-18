//
//  OutOfCreditViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

protocol OutOfCreditViewControllerDelegate: class {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int)
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton, selectedIndex: Int)
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int)
}

class OutOfCreditViewController: UIViewController {
    
    @IBOutlet weak var gradientTitleView: GradientView!

    @IBOutlet var inviteButton: UIButton!
    @IBOutlet var reloadButton: UIButton!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    var canReload: Bool = true
    var hasCredits: Bool = false
    
    weak var delegate: OutOfCreditViewControllerDelegate!

    var selectedIndex: Int = NSNotFound
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.hasCredits && self.canReload {
            
            self.inviteButton.isHidden = true
            self.reloadButton.isHidden = false
            
            self.titleLabel.text = "Reload Now"
            self.detailLabel.text = "Reload now to use Credits and access all offers"
            
        } else if self.canReload {
            self.inviteButton.isHidden = false
            self.reloadButton.isHidden = false
            
            self.detailLabel.text = "Reload now to access all offers and use Credits\nGet more Credits by sharing offers or Inviting Friends"
        } else {
            self.reloadButton.isHidden = true
            self.inviteButton.isHidden = false
            
            self.detailLabel.text = "Don’t worry, get more Credits by sharing offers or Inviting Friends"
        }
        
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, closeButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, reloadButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
        
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, inviteButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
        
    }
    
}
