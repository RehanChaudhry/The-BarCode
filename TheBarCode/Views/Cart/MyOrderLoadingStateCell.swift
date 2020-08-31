//
//  MyOrderLoadingStateCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol MyOrderLoadingStateCellDelegate: class {
    func myOrderLoadingStateCell(cell: MyOrderLoadingStateCell, bgButtonTapped sender: UIButton)
}

class MyOrderLoadingStateCell: UITableViewCell, NibReusable {

    @IBOutlet var contentContainer: UIView!
    @IBOutlet var loadingContainer: UIView!
    
    @IBOutlet var loader: UIActivityIndicatorView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    @IBOutlet var bgButton: UIButton!
    
    weak var delegate: MyOrderLoadingStateCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showLoading() {
        self.contentContainer.isHidden = true
        self.loadingContainer.isHidden = false
        
        self.loader.startAnimating()
    }
    
    func show(title: String, subtitle: String) {
        self.titleLabel.text = title
        self.detailLabel.text = subtitle
        
        self.contentContainer.isHidden = false
        self.loadingContainer.isHidden = true
    }
    
    //MARK: My IBActions
    @IBAction func bgButtonTapped(sender: UIButton) {
        self.delegate?.myOrderLoadingStateCell(cell: self, bgButtonTapped: sender)
    }
    
}
