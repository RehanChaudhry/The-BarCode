//
//  AllSearchViewMoreCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AllSearchViewMoreCellDelegate: class {
    func allSearchViewMoreCell(cell: AllSearchViewMoreCell, viewMoreButtonTapped sender: UIButton)
}

class AllSearchViewMoreCell: UITableViewCell, NibReusable {

    @IBOutlet var viewMoreButton: UIButton!
    
    weak var delegate: AllSearchViewMoreCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(model: AllSearchViewMoreModel) {
        self.viewMoreButton.setTitleColor(model.footerStrokeColor, for: .normal)
    }
    
    //MARK: My IBActions
    @IBAction func viewMoreButtonTapped(sender: UIButton) {
        self.delegate.allSearchViewMoreCell(cell: self, viewMoreButtonTapped: sender)
    }
}
