//
//  OrderStatusTableViewCell.swift
//  TheBarCode
//
//  Created by Macbook on 21/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderStatusTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusButton: UIButton!

    @IBOutlet var topMargin: NSLayoutConstraint!
    @IBOutlet var bottomMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.statusButton.titleLabel?.textAlignment = .center
        self.statusButton.titleLabel?.numberOfLines = 0
        self.statusButton.titleLabel?.lineBreakMode = .byWordWrapping
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showSeparator(show: Bool) {
        if show {
            self.separatorInset = UIEdgeInsetsMake(0.0, 16.0, 0.0, 16.0)
        } else {
            self.separatorInset = UIEdgeInsetsMake(0.0, 2000, 0.0, 0.0)
        }
    }
    
    func setupCell(orderStatusInfo: OrderStatusInfo, showSeparator: Bool) {
        
        self.titleLabel.text = "ORDER # \(orderStatusInfo.orderNo) STATUS:"
        self.statusButton.isHidden = false
        
        self.statusButton.setTitle(orderStatusInfo.status.uppercased(), for: .normal)
        
        if orderStatusInfo.status.lowercased() == OrderStatus.rejected.rawValue.lowercased() {
            self.statusButton.backgroundColor = UIColor.red
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
        } else if orderStatusInfo.status.lowercased() ==  OrderStatus.completed.rawValue.lowercased() {
            self.statusButton.backgroundColor = UIColor.appGreenColor()
            self.statusButton.setTitleColor(UIColor.appBgGrayColor(), for: .normal)
        } else {
            self.statusButton.backgroundColor = UIColor.appBlueColor()
            self.statusButton.setTitleColor(UIColor.appBgGrayColor(), for: .normal)
        }
        
        self.showSeparator(show: showSeparator)
        
        self.topMargin.constant = 29.0
        self.bottomMargin.constant = 29.0
    }
    
    func setupCell(heading: Heading, showSeparator: Bool) {
        self.titleLabel.text = heading.title
        self.statusButton.isHidden = true

        self.showSeparator(show: showSeparator)
        
        self.topMargin.constant = 24.0
        self.bottomMargin.constant = 16.0
    }
}
