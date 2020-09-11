//
//  OrderOfferTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 03/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol OrderRadioButtonTableViewCellDelegate: class {
    func orderRadioButtonTableViewCell(cell: OrderRadioButtonTableViewCell, radioButtonTapped sender: UIButton)
}

class OrderRadioButtonTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleButton: UIButton!
    @IBOutlet var checkBoxButton: UIButton!
    
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var selectionView: UIView!
    
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    weak var delegate: OrderRadioButtonTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionView.layer.cornerRadius = 10
        self.selectionView.layer.borderWidth = 4
        self.selectionView.layer.borderColor = UIColor.appRadioBgColor().cgColor
        
        self.titleButton.setTitleColor(UIColor.white, for: .normal)
        self.titleButton.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .disabled)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }
    
    func setupCell(orderOfferInfo: OrderDiscount, showSeparator: Bool) {
        
        self.subTitleLabel.text = ""
        
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(orderOfferInfo.text, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.selectionView.backgroundColor = orderOfferInfo.isSelected ? UIColor.appBlueColor() : UIColor.appRadioBgColor()
        
        self.showSeparator(show: showSeparator)
        
        if showSeparator {
            self.bottomMargin.constant = 24.0
        } else {
            self.bottomMargin.constant = 8.0
        }
        
        self.checkBoxButton.isEnabled = true
        self.titleButton.isEnabled = true
    }
    
    func setUpCell(radioButton: OrderRadioButton) {
        
        if radioButton.value > 0.0 {
            self.subTitleLabel.text = String(format: "£ %.2f", radioButton.value)
        } else {
            self.subTitleLabel.text = radioButton.subTitle
        }
        
        self.bottomMargin.constant = 8.0
        
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(radioButton.title, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.selectionView.backgroundColor = radioButton.isSelected ? UIColor.appBlueColor() : UIColor.appRadioBgColor()
        
        self.checkBoxButton.isEnabled = radioButton.isEnabled
        self.titleButton.isEnabled = radioButton.isEnabled
        
        self.showSeparator(show: false)
    }
    
    //MARK: My IBActions
    @IBAction func radioButtonTapped(sender: UIButton) {
        self.delegate?.orderRadioButtonTableViewCell(cell: self, radioButtonTapped: sender)
    }
    
}
