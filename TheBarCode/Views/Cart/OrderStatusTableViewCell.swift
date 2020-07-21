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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


    func setupCell(orderStatusInfo: OrderStatusInfo) {
        
        self.titleLabel.text = "ORDER # \(orderStatusInfo.orderNo) STATUS:"
        self.statusButton.isHidden = false
        
        self.statusButton.setTitle(orderStatusInfo.status.rawValue.uppercased(), for: .normal)
        if orderStatusInfo.status ==  .completed {
            self.statusButton.backgroundColor = UIColor.appGreenColor()
        } else if orderStatusInfo.status == .received || orderStatusInfo.status == .inProgress {
            self.statusButton.backgroundColor = UIColor.appBlueColor()
        }
    }
    
    func setupCell(heading: Heading) {
        self.titleLabel.text = heading.title
        self.statusButton.isHidden = true

    }
}
