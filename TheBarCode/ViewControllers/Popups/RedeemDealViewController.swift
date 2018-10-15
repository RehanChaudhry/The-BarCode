//
//  RedeemDealViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 12/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class RedeemDealViewController: CodeVerificationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: My IBActions
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

}
