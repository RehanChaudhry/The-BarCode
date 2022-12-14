//
//  AddNewCardCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 30/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AddNewCardCellDelegate: class {
    func addNewCardCell(cell: AddNewCardCell, addNewCardButtonTapped sender: UIButton)
}

class AddNewCardCell: UITableViewCell, NibReusable {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var actionButton: UIButton!
    
    @IBOutlet var checkmarkImageView: UIImageView!
    
    weak var delegate: AddNewCardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.separatorInset = UIEdgeInsetsMake(0.0, 4000, 0.0, 0.0)
        
        self.checkmarkImageView.tintColor = UIColor.appBlueColor()
        self.checkmarkImageView.image = self.checkmarkImageView.image?.withRenderingMode(.alwaysTemplate)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func maskCorners(radius: CGFloat, mask: CACornerMask) {
        if #available(iOS 11.0, *) {
            self.containerView.layer.cornerRadius = radius
            self.containerView.layer.maskedCorners = mask
        }
    }
    
    func setup(gatewayType: PaymentGatewayType, isSelectedNewPaymentCard: Bool) {
        if gatewayType == PaymentGatewayType.paymentSense {
            self.checkmarkImageView.isHidden = !isSelectedNewPaymentCard
            self.actionButton.setTitle("New Payment Card", for: .normal)
        } else {
            self.actionButton.setTitle("+ Add Payment Method", for: .normal)
            self.checkmarkImageView.isHidden = true
        }
    }
    
    //MARK: My IBActions
    @IBAction func addCardButtonTapped(sender: UIButton) {
        self.delegate?.addNewCardCell(cell: self, addNewCardButtonTapped: sender)
    }
    
}
