//
//  AllSearchFooterView.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AllSearchExtendedFooterViewDelegate: class {
    func allSearchExtendedFooterView(footerView: AllSearchFooterView, viewMoreButtonTapped sender: UIButton)
}

class AllSearchFooterView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var viewMoreButton: UIButton!
    
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var viewMoreButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var separatorHeight: NSLayoutConstraint!
    
    var section: Int!
    
    weak var delegate: AllSearchExtendedFooterViewDelegate!
    
    var footerViewModel: AllSearchFooterViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorView.backgroundColor = UIColor(red: 200.0/255.0, green: 199.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    
    //MARK: My Methods
    func setupFooterView(model: AllSearchFooterViewModel, isExpanded: Bool) {
        
        self.footerViewModel = model
        
        self.separatorView.isHidden = true
        self.separatorHeight.constant = 0.0
        self.separatorView.backgroundColor = UIColor.clear

        if model.shouldShowViewMoreButon {
            self.viewMoreButton.isHidden = false
            self.viewMoreButtonHeight.constant = 29.0
            self.viewMoreButton.setTitleColor(model.footerStrokeColor, for: .normal)
        } else {
            self.viewMoreButton.isHidden = true
            self.viewMoreButtonHeight.constant = 0.0
            self.viewMoreButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        }
        
        self.layoutIfNeeded()
    }
    
    //MARK: My IBActions
    @IBAction func viewMoreButtonTapped(sender: UIButton) {
        self.delegate.allSearchExtendedFooterView(footerView: self, viewMoreButtonTapped: sender)
    }
}
