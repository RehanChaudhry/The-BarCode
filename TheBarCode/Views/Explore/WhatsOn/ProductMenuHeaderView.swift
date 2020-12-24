//
//  ProductMenuHeaderView.swift
//  TheBarCode
//
//  Created by Mac OS X on 04/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ProductMenuHeaderViewDelegate: class {
    func foodMenuHeaderView(header: ProductMenuHeaderView, titleButtonTapped sender: UIButton)
}

class ProductMenuHeaderView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var accordionImageView: UIImageView!
    
    var section: Int = 0
    
    weak var delegate: ProductMenuHeaderViewDelegate?
    
    func setupHeader(title: String, isExpanded: Bool) {
        self.titleLabel.text = title.uppercased()
        
        self.accordionImageView.image = UIImage(named: "icon_accordion")
        
        if isExpanded {
            self.accordionImageView.transform = CGAffineTransform(rotationAngle: 0.0)
        } else {
            let degress = 270.0 * Double.pi / 180.0
            self.accordionImageView.transform = CGAffineTransform(rotationAngle: CGFloat(degress))
        }
    }

    //MARK: My IBActions
    @IBAction func titleButtonTapped(sender: UIButton) {
        self.delegate?.foodMenuHeaderView(header: self, titleButtonTapped: sender)
    }
}
