//
//  FoodMenuCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol ProductMenuCellDelegate: class {
    func productMenuCell(cell: ProductMenuCell, addToCartButtonTapped sender: UIButton)
    func productMenuCell(cell: ProductMenuCell, removeFromCartButtonTapped sender: UIButton)
}

class ProductMenuCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet weak var productImage: AsyncImageView!
    
    @IBOutlet var priceContainer: UIView!
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var cartIconContainer: UIView!
    
    @IBOutlet var cartIconImageView: UIImageView!
    
    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailLabelTop: NSLayoutConstraint!
    @IBOutlet var priceContainerHeight: NSLayoutConstraint!
    @IBOutlet var priceContainerTop: NSLayoutConstraint!
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    @IBOutlet var cartIconContainerWidth: NSLayoutConstraint!
    @IBOutlet var priceLabelLeft: NSLayoutConstraint!
    @IBOutlet var priceLabelRight: NSLayoutConstraint!
    @IBOutlet weak var productImageConstraint: NSLayoutConstraint!
    
    @IBOutlet var addItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var addItemButton: UIButton!
    
    @IBOutlet var removeItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var removeItemButton: UIButton!
    
    @IBOutlet var deliveryOnlyLabel: UILabel!
    
    @IBOutlet weak var deliveryOnlyLabelHeight: NSLayoutConstraint!
    @IBOutlet var deliveryOnlyLabelWidth: NSLayoutConstraint!
    @IBOutlet var deliveryOnlyLabelLeft: NSLayoutConstraint!
    
    weak var delegate: ProductMenuCellDelegate!
    
    enum CartIconType: String {
        case none = "none",
        priceWithCartIcon = "priceWithCartIcon",
        priceWithOutCartIcon = "withOutCartIcon",
        cartIconOnly = "cartIconOnly"
    }
    
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
    
    func setupCell(product: Product, bar: Bar) {
        
        self.titleLabel.attributedText = product.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = product.detail.value.html2Attributed(isTitle: false)
        
        if product.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 0.0
        }
        
        if product.image.value != "" {
            let url = URL(string: product.image.value)
            
            self.productImage.layer.cornerRadius = 15
            self.productImage.clipsToBounds = true
            self.productImage.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
            self.productImageConstraint.constant = 200
            self.titleLabelTopConstraint.constant = 10
        } else {
            self.productImageConstraint.constant = 0
            self.titleLabelTopConstraint.constant = 0
        }
        
        self.handlePrice(product: product, bar: bar)

        self.removeItemButton.isHidden = product.quantity.value == 0
        self.addItemButton.isUserInteractionEnabled = bar.isInAppPaymentOn.value
        
        UIView.performWithoutAnimation {
            let suffix = product.quantity.value > 1 ? "Items Added" : "Item Added"
            self.removeItemButton.setTitle("\(product.quantity.value) \(suffix) ", for: .normal)
            self.removeItemButton.layoutIfNeeded()
        }
        
        if bar.isInAppPaymentOn.value {
            self.shouldEnableCartButtons(enable: !(product.isAddingToCart || product.isRemovingFromCart))
        } else {
            self.addItemButton.isUserInteractionEnabled = false
        }
        
        if product.isDeliveryOnly.value {
            self.deliveryOnlyLabel.isHidden = false
            self.deliveryOnlyLabelWidth.constant = 110.0
            self.deliveryOnlyLabelHeight.constant = 28.0
//            self.deliveryOnlyLabelLeft.constant = 8.0
        } else {
            self.deliveryOnlyLabel.isHidden = true
            self.deliveryOnlyLabelWidth.constant = 0.0
            self.deliveryOnlyLabelHeight.constant = 0.0
//            self.deliveryOnlyLabelLeft.constant = 0.0
        }
        
        self.handleAddingToCart(isAdding: product.isAddingToCart)
        self.handleRemoveFromCart(isRemoving: product.isRemovingFromCart)
    }
    
    func handlePrice(product: Product, bar: Bar) {
        
        let price = Double(product.price.value) ?? 0.0
        
        if bar.isInAppPaymentOn.value {
            if product.haveModifiers.value {
                self.priceLabel.text = price > 0 ? "\(bar.currencySymbol.value) " + String(format: "%.2f", price) : ""
                self.setupCartIcon(type: price > 0 ? .priceWithCartIcon : .cartIconOnly)
            } else {
                self.priceLabel.text = "\(bar.currencySymbol.value) " + String(format: "%.2f", price)
                self.setupCartIcon(type: price > 0 ? .priceWithCartIcon : .none)
            }
        } else {
            self.priceLabel.text = "\(bar.currencySymbol.value) " + String(format: "%.2f", price)
            self.setupCartIcon(type: price > 0 ? .priceWithOutCartIcon : .none)
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
        
    func setupCartIcon(type: CartIconType) {
        switch type {
        case .none:
            self.cartIconContainerWidth.constant = 0.0
            self.priceLabelLeft.constant = 0.0
            self.priceLabelRight.constant = 0.0
            
            self.priceContainerTop.constant = 0.0
            self.priceContainerHeight.constant = 0.0
            
            self.cartIconContainer.isHidden = true
            self.priceContainer.isHidden = true
        case .cartIconOnly:
            self.cartIconContainerWidth.constant = 38.0
            self.priceLabelLeft.constant = 0.0
            self.priceLabelRight.constant = 0.0
            
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.cartIconContainer.isHidden = false
            self.priceContainer.isHidden = false
        case .priceWithCartIcon:
            self.cartIconContainerWidth.constant = 38.0
            self.priceLabelLeft.constant = 8.0
            self.priceLabelRight.constant = 12.0
            
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.cartIconContainer.isHidden = false
            self.priceContainer.isHidden = false
        case .priceWithOutCartIcon:
            self.cartIconContainerWidth.constant = 0.0
            self.priceLabelLeft.constant = 12.0
            self.priceLabelRight.constant = 12.0
            
            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 28.0
            
            self.cartIconContainer.isHidden = true
            self.priceContainer.isHidden = false
        }
    }
    
    //MARK: My IBActions
    @IBAction func removeItemButtonTapped(sender: UIButton) {
        self.delegate.productMenuCell(cell: self, removeFromCartButtonTapped: sender)
    }
    
    @IBAction func addItemButtonTapped(sender: UIButton) {
        self.delegate.productMenuCell(cell: self, addToCartButtonTapped: sender)
    }
}


