//
//  LoadingButton.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

class LoadingButton: UIButton {

    var activityIndicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activityIndicator.color = UIColor.black
        self.activityIndicator.hidesWhenStopped = true
        self.addSubview(self.activityIndicator)
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self, withOffset: -16.0)
        self.activityIndicator.autoAlignAxis(ALAxis.horizontal, toSameAxisOf: self)
        
    }
    
    func updateAcivityIndicatorColor(color: UIColor) {
        self.activityIndicator.color = color
    }
    
    func showLoader() {
        self.activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        self.activityIndicator.stopAnimating()
    }

}
