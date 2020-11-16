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

    @IBOutlet var orderNoLabel: UILabel!
    @IBOutlet var barNameLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
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
        self.barNameLabel.text = order.barName + " - " + order.orderType.displayableValue()
        
        let amount = order.paymentSplit.first?.amount ?? 0.0
        self.priceLabel.text = String(format: "£ %.2f", amount)
        
        self.statusButton.titleLabel?.lineBreakMode = .byWordWrapping
        self.statusButton.titleLabel?.numberOfLines = 0
        self.statusButton.titleLabel?.textAlignment = .center
        self.statusButton.setTitle(order.statusRaw.uppercased(), for: .normal)
        
        if order.status == .rejected {
            self.statusButton.backgroundColor = UIColor.red
            self.statusButton.setTitleColor(UIColor.white, for: .normal)
        } else if order.status ==  .completed {
            self.statusButton.backgroundColor = UIColor.appGreenColor()
            self.statusButton.setTitleColor(UIColor.appBgGrayColor(), for: .normal)
        } else {
            self.statusButton.backgroundColor = UIColor.appBlueColor()
            self.statusButton.setTitleColor(UIColor.appBgGrayColor(), for: .normal)
        }
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        self.dateLabel.text = dateformatter.string(from: order.updatedAt)
        
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
