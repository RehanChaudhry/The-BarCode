//
//  RulesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 13/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FirebaseAnalytics

class RulesViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal)
        
        textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 20)
        Analytics.logEvent(viewRedemptionRulesScreen, parameters: nil)
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
