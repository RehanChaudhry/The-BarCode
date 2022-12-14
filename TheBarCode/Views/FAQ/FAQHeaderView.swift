//
//  FAQHeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 14/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol FAQHeaderViewDelegate: class {
    func faqHeaderView(headerView: FAQHeaderView, didSelectAtSection section: Int)
}

class FAQHeaderView: UITableViewHeaderFooterView, NibReusable {
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var titleButton: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    
    var section = 0
    
    weak var delegate: FAQHeaderViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headerView.layer.borderColor = UIColor.appGradientGrayEnd().cgColor
    }
    
    //MARK: My Methods
    
    func setUpHeaderView(faqSection: FAQSection, isOpen: Bool) {
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(faqSection.title, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        if isOpen {
            self.imageView.transform = CGAffineTransform(rotationAngle: (CGFloat.pi / 180.0) * (-180.0))
        } else {
            self.imageView.transform = CGAffineTransform(rotationAngle: 0.0)
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func headerBgButtonTapped(sender: UIButton) {
        self.delegate.faqHeaderView(headerView: self, didSelectAtSection: self.section)
    }
}
