//
//  AllSearchExtendedFooterView.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AllSearchExtendedFooterViewDelegate: class {
    func allSearchExtendedFooterView(footerView: AllSearchExtendedFooterView, expandableButtonTapped sender: UIButton)
    func allSearchExtendedFooterView(footerView: AllSearchExtendedFooterView, viewMoreButtonTapped sender: UIButton)
}

class AllSearchExtendedFooterView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var resultsButton: UIButton!
    @IBOutlet var viewMoreButton: UIButton!
    
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var viewMoreButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var resultsButtonTop: NSLayoutConstraint!
    @IBOutlet var resultsButtonHeight: NSLayoutConstraint!
    
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
        
        if model.shouldShowSeparator {
            self.separatorView.isHidden = false
        } else {
            self.separatorView.isHidden = true
        }
        
        if model.shouldShowExpandButton {
            self.resultsButton.isHidden = false
            self.resultsButtonHeight.constant = 29.0
        } else {
            self.resultsButton.isHidden = true
            self.resultsButtonHeight.constant = 0.0
        }
        
        if model.shouldShowViewMoreButon {
            self.viewMoreButton.isHidden = false
            self.viewMoreButtonHeight.constant = 29.0
        } else {
            self.viewMoreButton.isHidden = true
            self.viewMoreButtonHeight.constant = 0.0
        }
        
        if isExpanded {
            UIView.performWithoutAnimation {
                self.resultsButton.setTitle("View Less Results", for: .normal)
                self.resultsButton.layoutIfNeeded()
            }
        } else {
            UIView.performWithoutAnimation {
                self.resultsButton.setTitle("View All Results", for: .normal)
                self.resultsButton.layoutIfNeeded()
            }
        }
        
        self.layoutIfNeeded()
    }
    
    //MARK: My IBActions
    @IBAction func viewAllResultsButtonTapped(sender: UIButton) {
        self.delegate.allSearchExtendedFooterView(footerView: self, expandableButtonTapped: sender)
    }
    
    @IBAction func viewMoreButtonTapped(sender: UIButton) {
        self.delegate.allSearchExtendedFooterView(footerView: self, viewMoreButtonTapped: sender)
    }
}
