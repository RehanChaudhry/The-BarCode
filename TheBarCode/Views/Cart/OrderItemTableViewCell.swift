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
    
    @IBOutlet var quantityUpdateIndicator: UIActivityIndicatorView!
    @IBOutlet var deleteIndicator: UIActivityIndicatorView!
    
    weak var delegate: OrderItemTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpCell(order: Order, orderItem: OrderItem) {
        
        self.nameLabel.text = orderItem.name
        
        let priceString = String(format: "%.2f", orderItem.totalUnitPrice)
        self.unitPriceLabel.text = "x \(order.currencySymbol) " + priceString
        
        let totalPriceString = String(format: "%.2f", orderItem.totalPrice)
        self.totalPriceLabel.text = "\(order.currencySymbol) " + totalPriceString

        self.stepperView.delegate = self
        
        self.stepperView.value = orderItem.quantity
        
        let image = UIImage(named: "icon_trash")?.withRenderingMode(.alwaysTemplate)
        self.deleteButton.setImage(image, for: .normal)
        self.deleteButton.tintColor = UIColor.white
        
        self.stepperView.isUserInteractionEnabled = !(orderItem.isDeleting || orderItem.isUpdating)
        self.deleteButton.isUserInteractionEnabled = !(orderItem.isDeleting || orderItem.isUpdating)
        
        self.deleteButton.isHidden = orderItem.isDeleting
        
        if orderItem.isDeleting {
            self.deleteIndicator.startAnimating()
        } else {
            self.deleteIndicator.stopAnimating()
        }
        
        if orderItem.isUpdating {
            self.quantityUpdateIndicator.startAnimating()
        } else {
            self.quantityUpdateIndicator.stopAnimating()
        }
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        self.delegate.orderItemTableViewCell(cell: self, deleteButtonTapped: sender)
    }
}

//MARK: StepperViewDelegate
extension OrderItemTableViewCell: StepperViewDelegate {
    func stepperView(stepperView: StepperView, valueChanged value: Int) {
        self.delegate.orderItemTableViewCell(cell: self, stepperValueChanged: stepperView)
    }
}
