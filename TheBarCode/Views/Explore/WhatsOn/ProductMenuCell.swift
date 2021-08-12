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
    func productMenuCell(cell: ProductMenuCell, selectedIndexPath: IndexPath)
}

class ProductMenuCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet weak var productImage: AsyncImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var priceContainer: UIView!
    @IBOutlet var separatorView: UIView!
    
    @IBOutlet var cartIconContainer: UIView!
    
    @IBOutlet var cartIconImageView: UIImageView!
    
//    @IBOutlet weak var titleLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet var detailLabelTop: NSLayoutConstraint!
    @IBOutlet var priceContainerHeight: NSLayoutConstraint!
//    @IBOutlet var priceContainerTop: NSLayoutConstraint!
//    @IBOutlet var topPadding: NSLayoutConstraint!
    
    @IBOutlet weak var priceContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerTop: NSLayoutConstraint!
    @IBOutlet weak var seperatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewContainerHeight: NSLayoutConstraint!
    @IBOutlet var cartIconContainerWidth: NSLayoutConstraint!
    @IBOutlet var priceLabelLeft: NSLayoutConstraint!
    @IBOutlet var priceLabelRight: NSLayoutConstraint!
    @IBOutlet weak var productImageConstraint: NSLayoutConstraint!
    @IBOutlet weak var productImageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet var addItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var addItemButton: UIButton!
    
    @IBOutlet var removeItemActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var removeItemButton: UIButton!
    
    @IBOutlet var deliveryOnlyLabel: UILabel!
    
    @IBOutlet weak var deliveryOnlyLabelHeight: NSLayoutConstraint!
    @IBOutlet var deliveryOnlyLabelWidth: NSLayoutConstraint!
//    @IBOutlet var deliveryOnlyLabelLeft: NSLayoutConstraint!
    
    weak var delegate: ProductMenuCellDelegate!
    var givenProduct: Product!
    //var relatedProducts: [RelatedProductModel] = []
    
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
//        self.setDelegates()
    }
    
    func setDelegates() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(cellType: SimilarProductsCell.self)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(product: Product, bar: Bar) {
        
        self.titleLabel.attributedText = product.name.value.html2Attributed(isTitle: true)
        self.detailLabel.attributedText = product.detail.value.html2Attributed(isTitle: false)
        
        self.priceContainer.layer.cornerRadius = 10
        self.givenProduct = product
        if product.detail.value.count > 0 {
            self.detailLabelTop.constant = 10.0
        } else {
            self.detailLabelTop.constant = 5.0
        }
        
        if product.image.value != "" {
            let url = URL(string: product.image.value)
            
            self.productImage.layer.cornerRadius = 10
            self.productImage.clipsToBounds = true
            self.productImage.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        }else {
            self.productImageConstraint.constant = 0
            self.productImageWidthConstraint.constant = 0
        }
        
        //self.relatedProducts = product.relatedProducts
        
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
//        if product.relatedProducts.count > 0 {
//            self.collectionView.reloadData()
//        }else {
//            self.collectionViewContainerHeight.constant = 0
//            self.collectionContainerHeight.constant = 0
//            self.collectionContainerTop.constant = 10.0
//        }
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
            
//            self.priceContainerTop.constant = 0.0
            self.priceContainerHeight.constant = 0.0
            
            self.cartIconContainer.isHidden = true
            self.priceContainer.isHidden = true
        case .cartIconOnly:
            self.cartIconContainerWidth.constant = 38.0
            self.priceLabelLeft.constant = 0.0
            self.priceLabelRight.constant = 0.0
            
//            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 40.0
            
            self.cartIconContainer.isHidden = false
            self.priceContainer.isHidden = false
        case .priceWithCartIcon:
            self.cartIconContainerWidth.constant = 38.0
            self.priceLabelLeft.constant = 8.0
            self.priceLabelRight.constant = 12.0
            
//            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 40.0
            
            self.cartIconContainer.isHidden = false
            self.priceContainer.isHidden = false
        case .priceWithOutCartIcon:
            self.cartIconContainerWidth.constant = 0.0
            self.priceLabelLeft.constant = 12.0
            self.priceLabelRight.constant = 12.0
            
//            self.priceContainerTop.constant = 8.0
            self.priceContainerHeight.constant = 40.0
            
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

// MARK:- COLLECTION VIEW DELEGATES & DATA SOURCE
extension ProductMenuCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SimilarProductsCell", for: indexPath) as! SimilarProductsCell
        DispatchQueue.main.async {
            cell.productImage.layer.cornerRadius = 10
            cell.productImage.clipsToBounds = true
        }
        let url = URL(string: self.givenProduct.image.value)
        cell.productImage.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 5, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = delegate {
            delegate?.productMenuCell(cell: self, selectedIndexPath: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}
