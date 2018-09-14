//
//  ReloadViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

class ReloadViewController: UIViewController {

    @IBOutlet var creditsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.creditsLabel.layer.borderColor = UIColor.appGradientGrayStart().cgColor
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
