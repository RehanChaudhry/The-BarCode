//
//  PrivacyPolicyViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 11/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}
