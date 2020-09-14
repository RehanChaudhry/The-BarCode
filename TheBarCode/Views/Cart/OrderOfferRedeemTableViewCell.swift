//
//  OrderOfferRedeemTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 04/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol OrderOfferRedeemTableViewCellDelegate: class {
    func orderOfferRedeemTableViewCell(cell: OrderOfferRedeemTableViewCell, redeemButtonTapped sender: UIButton)
}

class OrderOfferRedeemTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleButton: UIButton!
    
    weak var delegate: OrderOfferRedeemTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
    
    func setUpCell(orderOfferRedeem: OrderOfferRedeem) {
        UIView.performWithoutAnimation {
            self.titleButton.setTitle(orderOfferRedeem.title, for: .normal)
            self.titleButton.layoutIfNeeded()
        }
        
        self.showSeparator(show: false)
        
        self.titleButton.isUserInteractionEnabled = orderOfferRedeem.shouldEnableButton
    }
    
    //MARK: My IBActions
    @IBAction func redeemButtonTapped(sender: UIButton) {
        self.delegate?.orderOfferRedeemTableViewCell(cell: self, redeemButtonTapped: sender)
    }
}
