//
//  ProductModifierCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/12/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ProductModifierCellDelegate: class {
    func productModifierCell(cell: ProductModifierCell, selectionButtonTapped sender: UIButton)
    func productModifierCell(cell: ProductModifierCell, stepperValueChanged stepper: StepperView, value: Int)
}

class ProductModifierCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var productPriceLabel: UILabel!
    
    @IBOutlet var quantityPriceLabel: UILabel!
    
    @IBOutlet var stepperContainerView: UIView!
    
    @IBOutlet var selectionView: UIView!
    @IBOutlet var selectionContainerView: UIView!
    
    @IBOutlet var stepperView: StepperView!
    
    @IBOutlet var stepperContainerHeight: NSLayoutConstraint!
    
    weak var delegate: ProductModifierCellDelegate!
    
    var showBottomView: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(modifier: ProductModifier, group: ProductModifierGroup, regionInfo: RegionInfo) {
        
        if group.isMultiSelectionAllowed {
            self.selectionContainerView.layer.cornerRadius = 4.0
            self.selectionView.layer.cornerRadius = 2.0
        } else {
            self.selectionContainerView.layer.cornerRadius = (self.selectionContainerView.frame.size.height / 2.0)
            self.selectionView.layer.cornerRadius = (self.selectionView.frame.size.height / 2.0)
        }

        self.selectionView.isHidden = !modifier.isSelected
        
        if modifier.quantity > 0 && group.max > 1 && group.multiSelectMax > 1 {
            self.stepperContainerHeight.constant = 32.0
        } else {
            self.stepperContainerHeight.constant = 0.0
        }
        
        self.titleLabel.text = modifier.name
        self.productPriceLabel.text = String(format: "\(regionInfo.currencySymbol) %.2f", modifier.price)
        self.quantityPriceLabel.text = String(format: "\(regionInfo.currencySymbol) %.2f", modifier.price * Double(modifier.quantity))
        
        self.stepperView.minValue = 0
        self.stepperView.maxValue = group.multiSelectMax
        self.stepperView.value = modifier.quantity
        
        let selectedQuantity = group.selectedModifiersQuantity
        if selectedQuantity < group.max {
            self.stepperView.incrementButton.isEnabled = modifier.quantity < group.multiSelectMax
        } else {
            self.stepperView.incrementButton.isEnabled = false
        }
        
        self.stepperView.delegate = self
    }
    
    //MARK: My IBActions
    @IBAction func selectionButtonTapped(sender: UIButton) {
        self.delegate.productModifierCell(cell: self, selectionButtonTapped: sender)
    }
}

//MARK: StepperViewDelegate
extension ProductModifierCell: StepperViewDelegate {
    func stepperView(stepperView: StepperView, valueChanged value: Int) {
        self.delegate.productModifierCell(cell: self, stepperValueChanged: stepperView, value: value)
    }
}
