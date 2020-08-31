//
//  MyOrderFooterView.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol MyOrderFooterViewDelegate: class {
    func myOrderFooterView(footerView: MyOrderFooterView, viewMoreButtonTapped sender: UIButton)
}

class MyOrderFooterView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var button: UIButton!

    weak var delegate: MyOrderFooterViewDelegate?
    
    var section: Int = 0
    
    //MARK: My Methods
    func setUpFooterView(title: String) {
        UIView.performWithoutAnimation {
            self.button.setTitle(title, for: .normal)
            self.button.layoutIfNeeded()
        }
    }
    
    //MARK: My IBActions
    @IBAction func viewMoreButtonTapped(sender: UIButton) {
        self.delegate?.myOrderFooterView(footerView: self, viewMoreButtonTapped: sender)
    }
}
