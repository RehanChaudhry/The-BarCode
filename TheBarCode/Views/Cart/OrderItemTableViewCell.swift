//
//  OrderItemTableViewCell.swift
//  TheBarCode
//
//  Created by Macbook on 17/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol OrderItemTableViewCellDelegate : class {
    func orderItemTableViewCell(cell: OrderItemTableViewCell, deleteButtonTapped sender: UIButton)
    func orderItemTableViewCell(cell: OrderItemTableViewCell, stepperValueChanged stepper: StepperView)
}


class OrderItemTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var stepperView: StepperView!
    @IBOutlet var unitPriceLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    
    var delegate: OrderItemTableViewCellDelegate!
    
    var orderItem: OrderItem!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpCell(orderItem: OrderItem) {
        
        self.nameLabel.text = orderItem.name
        
        let priceString = String(format: "%.2f", orderItem.unitPrice)
        self.unitPriceLabel.text = "x £ " + priceString
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.totalPriceLabel.text = "£ " + totalPriceString

        self.stepperView.delegate = self
        
        let image = UIImage(named: "icon_trash")?.withRenderingMode(.alwaysTemplate)
        self.deleteButton.setImage(image, for: .normal)
        self.deleteButton.tintColor = UIColor.white
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate.orderItemTableViewCell(cell: self, deleteButtonTapped: sender)
    }
}




//MARK: StepperViewDelegate
extension OrderItemTableViewCell: StepperViewDelegate {
    func stepperView(stepperView: StepperView, valueChanged value: Int) {
        self.orderItem.quantity = value
        self.delegate.orderItemTableViewCell(cell: self, stepperValueChanged: stepperView)
    }
}
