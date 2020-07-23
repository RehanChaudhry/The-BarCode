//
//  OrderTableViewCell.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OrderTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var orderNoLabel: UILabel!
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var statusButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(order: Order) {
        
        self.orderNoLabel.text = "ORDER NO. " + order.orderNo
        self.barNameLabel.text = order.barName
        self.priceLabel.text = order.price
        
        self.statusButton.setTitle(order.status.rawValue.uppercased(), for: .normal)
        
        
        if order.status ==  .completed {
            self.statusButton.backgroundColor = UIColor.appGreenColor()
        } else if order.status == .received || order.status == .inProgress {
            self.statusButton.backgroundColor = UIColor.appBlueColor()

        }
    }
    
    func setUpCell(reservation: Reservation) {
        
        self.barNameLabel.text = reservation.barName
        self.priceLabel.text = "\( reservation.noOfPersons) Persons"
        self.statusButton.setTitle(reservation.status.rawValue.uppercased(), for: .normal)
        
        if reservation.status ==  .completed {
            
            self.statusButton.backgroundColor = UIColor.appGreenColor()
            self.orderNoLabel.text = "ORDER NO. " + reservation.orderNo

        } else if reservation.status == .valid {
            
            self.orderNoLabel.text = reservation.date + " at " + reservation.time
            self.statusButton.backgroundColor = UIColor.appBlueColor()
            
        } else if reservation.status == .cancelled {
            
            self.orderNoLabel.text = reservation.date + " at " + reservation.time
            self.statusButton.backgroundColor = UIColor.appRedColor()

        }
    }
}
