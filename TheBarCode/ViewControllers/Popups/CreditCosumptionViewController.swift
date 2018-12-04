//
//  CreditCosumptionViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

protocol CreditCosumptionViewControllerDelegate: class {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int)
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int)
}

class CreditCosumptionViewController: UIViewController {

    @IBOutlet weak var gradientTitleView: GradientView!
    
    weak var delegate: CreditCosumptionViewControllerDelegate!
    
    var selectedIndex: Int = NSNotFound
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        gradientTitleView.updateGradient(colors: [UIColor.appGreenColor(), UIColor.appBlueColor()], locations: nil, direction: .bottom)
        gradientTitleView.alpha = 0.34
    }
    
    //MARK: My IBAction
    @IBAction func yesButtonTapped(sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.creditConsumptionViewController(controller: self, yesButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }
    
    @IBAction func noButtonTapped(sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.creditConsumptionViewController(controller: self, noButtonTapped: sender, selectedIndex: self.selectedIndex)
        }
    }

}
