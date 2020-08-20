//
//  FoodMenuCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol FoodMenuCellDelegate: class {
    func foodMenuCell(cell: FoodMenuCell, addToCartButtonTapped sender: UIButton)
    func foodMenuCell(cell: FoodMenuCell, removeFromCartButtonTapped sender: UIButton)
}

class FoodMenuCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    @IBOutlet var priceContainer: UIView!
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var cartIconContainer: UIView!
    
    @IBOutlet var cartIconImageView: UIImageView!
    
    @IBOutlet var detailLabelTop: NSLayoutConstraint!
    @IBOutlet var priceContainerHeight: NSLayoutConstraint!
    @IBOutlet var priceContainerTop: NSLayoutConstraint!
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    @IBOutlet var cartIconContainerWidth: NSLayoutConstraint!
    @IBOutlet var priceLabelLeft: NSLayoutConstraint!
    
    @IBOutlet var addItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var addItemButton: UIButton!
    
    @IBOutlet var removeItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var removeItemButton: UIButton!
    
    weak var delegate: FoodMenuCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
        
        self.cartIconImageView.image = self.cartIconImageView.image?.withRenderingMode(.alwaysTemplate)
        self.removeItemButton.setImage(UIImage(named: "icon_trash_bin")?.tinted(with: UIColor.white), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCellForDrink(drink: Drink, isInAppPaymentOn: Bool) {
        
        self.titleLabel.attributedText = drink.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = drink.detail.value.html2Attributed(isTitle: false)
        
        if drink.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 0.0
        }
        
        let price = Double(drink.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "£ " + priceString
        
        self.handlePrice(price: price)
        
        self.shouldShowCartIcon(show: isInAppPaymentOn)
        
        self.removeItemButton.isHidden = drink.quantity.value == 0
        self.addItemButton.isUserInteractionEnabled = isInAppPaymentOn
        
        UIView.performWithoutAnimation {
            self.removeItemButton.setTitle("\(drink.quantity.value) Items Added ", for: .normal)
            self.removeItemButton.layoutIfNeeded()
        }
        
        if isInAppPaymentOn {
            self.shouldEnableCartButtons(enable: !(drink.isAddingToCart || drink.isRemovingFromCart))
        } else {
            self.addItemButton.isUserInteractionEnabled = false
        }
        
        self.handleAddingToCart(isAdding: drink.isAddingToCart)
        self.handleRemoveFromCart(isRemoving: drink.isRemovingFromCart)
    }
    
    func setupCellForFood(food: Food, isInAppPaymentOn: Bool) {
        
        self.titleLabel.attributedText = food.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = food.detail.value.html2Attributed(isTitle: false)
        
        if food.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 0.0
        }
        
        let price = Double(food.price.value) ?? 0.0
        let priceString = String(format: "%.2f", price)
        self.priceLabel.text = "£ " + priceString

        self.handlePrice(price: price)
        
        self.shouldShowCartIcon(show: isInAppPaymentOn)
        
        self.removeItemButton.isHidden = food.quantity.value == 0
        self.addItemButton.isUserInteractionEnabled = isInAppPaymentOn
        
        UIView.performWithoutAnimation {
            self.removeItemButton.setTitle("\(food.quantity.value) Items Added ", for: .normal)
            self.removeItemButton.layoutIfNeeded()
        }
        
        if isInAppPaymentOn {
            self.shouldEnableCartButtons(enable: !(food.isAddingToCart || food.isRemovingFromCart))
        } else {
            self.addItemButton.isUserInteractionEnabled = false
        }
        
        self.handleAddingToCart(isAdding: food.isAddingToCart)
        self.handleRemoveFromCart(isRemoving: food.isRemovingFromCart)
    }
    
    func handlePrice(price: Double) {
        if price <= 0.0 {
            self.priceContainerTop.constant = 0.0
            self.priceContainerHeight.constant = 0.0
            
            self.priceContainer.isHidden = true
        } else {
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.priceContainer.isHidden = false
        }
    }
    
    func handleAddingToCart(isAdding: Bool) {
        if isAdding {
            self.addItemActivityIndicator.startAnimating()
        } else {
            self.addItemActivityIndicator.stopAnimating()
        }
    }
    
    func handleRemoveFromCart(isRemoving: Bool) {
        if isRemoving {
            self.removeItemActivityIndicator.startAnimating()
        } else {
            self.removeItemActivityIndicator.stopAnimating()
        }
    }
    
    func shouldEnableCartButtons(enable: Bool) {
        self.removeItemButton.isUserInteractionEnabled = enable
        self.addItemButton.isUserInteractionEnabled = enable
    }
    
    func shouldShowCartIcon(show: Bool) {
        if show {
            self.cartIconContainer.isHidden = false
            self.cartIconContainerWidth.constant = 38.0
            self.priceLabelLeft.constant = 8.0
        } else {
            self.cartIconContainerWidth.constant = 0.0
            self.cartIconContainer.isHidden = true
            self.priceLabelLeft.constant = 12.0
        }
    }
    
    //MARK: My IBActions
    @IBAction func removeItemButtonTapped(sender: UIButton) {
        self.delegate.foodMenuCell(cell: self, removeFromCartButtonTapped: sender)
    }
    
    @IBAction func addItemButtonTapped(sender: UIButton) {
        self.delegate.foodMenuCell(cell: self, addToCartButtonTapped: sender)
    }
}


