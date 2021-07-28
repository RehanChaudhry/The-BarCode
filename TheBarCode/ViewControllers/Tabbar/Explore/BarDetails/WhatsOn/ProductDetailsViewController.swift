//
//  ProductDetailsViewController.swift
//  TheBarCode
//
//  Created by Zeeshan on 27/07/2021.
//  Copyright © 2021 Cygnis Media. All rights reserved.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    
    @IBOutlet weak var selectedProductImage: AsyncImageView!
    @IBOutlet weak var selectedProductTitle: UILabel!
    @IBOutlet weak var selectedProductDesc: UILabel!
    @IBOutlet weak var addToCartButton: GradientButton!
    
    var productTitle = ""
    var productDesc = ""
    var productImage = ""
    var productPrice = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavBar()
        self.setupUI()
    }
    
    func setNavBar() {
        self.navigationItem.title = "Product Details"
        let leftButton = UIBarButtonItem(image: UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(didPressBackButton))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func didPressBackButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func setupUI() {
        self.selectedProductTitle.text = self.productTitle
        self.selectedProductDesc.text = self.productDesc
        let url = URL(string: self.productImage)
        self.selectedProductImage.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.addToCartButton.setTitle("Add to Cart - £ " + self.productPrice, for: .normal)
    }
    
    @IBAction func addToCartAction(_ sender: GradientButton) {
        
    }
}
