//
//  OutOfCreditViewController.swift
//  TheBarCode
//
//  Created by Aasna Islam on 02/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

protocol OutOfCreditViewControllerDelegate: class {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton)
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton)
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton)
}

class OutOfCreditViewController: UIViewController {
    
    weak var delegate: OutOfCreditViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: IBActions
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, closeButtonTapped: sender)
        }
    }
    
    @IBAction func reloadButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, reloadButtonTapped: sender)
        }
        
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate.outOfCreditViewController(controller: self, inviteButtonTapped: sender)
        }
        
    }
    
}
