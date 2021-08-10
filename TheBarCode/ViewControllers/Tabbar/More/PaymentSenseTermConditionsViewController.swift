//
//  PaymentSenseTermConditionsViewController.swift
//  TheBarCode
//
//  Created by Zeeshan on 10/08/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit

class PaymentSenseTermConditionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
    }
    
    func setupNavBar() {
        self.title = "Paymentsense Terms"
        let leftButton = UIBarButtonItem(image: UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didTapBack))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didTapBack() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
