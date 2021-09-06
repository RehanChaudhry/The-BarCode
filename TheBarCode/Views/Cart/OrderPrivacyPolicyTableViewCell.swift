//
//  OrderPrivacyPolicyTableViewCell.swift
//  TheBarCode
//
//  Created by Rehan Chaudhry on 03/09/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol OrderPrivacyPolicyDelegate {
    func didTapOrderPrivacyPolicy()
    func didAgreeOrderPrivacy(state: Bool)
}

class OrderPrivacyPolicyTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    
    var orderPrivacyPolicy: OrderPrivacyPolicy!
    
    var delegate: OrderPrivacyPolicyDelegate!
    
    var isEnable = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(orderPrivacyPolicy: OrderPrivacyPolicy) {

        self.orderPrivacyPolicy = orderPrivacyPolicy
        
        self.selectionView.isHidden = !orderPrivacyPolicy.isDefault
        
        self.privacyPolicyLabel.attributedText = orderPrivacyPolicy.note
        
        self.showSeparator(show: false)
    }
    
    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        }
    }

    @IBAction func checkBoxButtonTapped(_ sender: UIButton) {
        
        self.orderPrivacyPolicy.isDefault = !self.orderPrivacyPolicy.isDefault
        self.setupCell(orderPrivacyPolicy: self.orderPrivacyPolicy)
        
        if let delegate = self.delegate {
            self.isEnable = !self.isEnable
            delegate.didAgreeOrderPrivacy(state: self.isEnable)
        }
        
    }
    
    @IBAction func openPrivacyPolicyTapped(_ sender: UIButton) {
        
        if let delegate = self.delegate {
            
            delegate.didTapOrderPrivacyPolicy()
        }
        
    }
    
   
    
}
