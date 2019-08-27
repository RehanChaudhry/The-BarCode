//
//  EmptyDataView.swift
//  Tree
//
//  Created by Mac OS X on 08/03/2017.
//  Copyright © 2017 abc. All rights reserved.
//

import UIKit
import Reusable

class EmptyDataView: UIView, NibLoadable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    @IBOutlet var actionButton: GradientButton!
    
    var actionHandler: ((_ sender: UIButton) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLabel.numberOfLines = 0
       // actionButton.backgroundColor = UIColor.appBlueColor()
    }
    
    
    func setTitle(title: String, desc: String, iconImageName: String?, buttonTitle: String) {
        titleLabel.text = title
        descriptionLabel.text = desc
        
        actionButton.setTitle(buttonTitle, for: .normal)
        
        if let iconImageName = iconImageName {
            actionButton.setImage(UIImage(named: iconImageName), for: .normal)
        }   
    }
    
    //MARK: My IBActions
    
    @IBAction func actionButtonTapped(sender: UIButton) {
        actionHandler?(sender)
    }

}
