//
//  AllSearchFooterView.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AllSearchFooterViewDelegate: class {
    func allSearchFooterView(footerView: AllSearchFooterView, viewMoreButtonTapped sender: UIButton)
}

class AllSearchFooterView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var separatorView: UIView!
    @IBOutlet var viewMoreButton: UIButton!
    
    weak var delegate: AllSearchFooterViewDelegate!
    
    var type: AllSearchItemType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.contentView.backgroundColor = UIColor.orange
    }
    
    func setup(footerType: AllSearchFooterType) {
        if footerType == .viewMore {
            self.viewMoreButton.isHidden = false
        } else {
            self.viewMoreButton.isHidden = true
        }
    }
    
    //MARK: My IBActions
    @IBAction func viewMoreButtonTapped(sender: UIButton) {
        self.delegate.allSearchFooterView(footerView: self, viewMoreButtonTapped: sender)
    }

}
