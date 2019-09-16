//
//  AllSearchFooterCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 05/09/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AllSearchFooterCellDelegate: class {
    func allSearchFooterCell(cell: AllSearchFooterCell, expandButtonTapped sender: UIButton)
}

class AllSearchFooterCell: UITableViewCell, NibReusable {

    @IBOutlet var expandButton: UIButton!
    
    weak var delegate: AllSearchFooterCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(isExpanded: Bool) {
        if isExpanded {
            UIView.performWithoutAnimation {
                self.expandButton.setTitle("View Less Results", for: .normal)
                self.expandButton.layoutIfNeeded()
            }
        } else {
            UIView.performWithoutAnimation {
                self.expandButton.setTitle("View All Results", for: .normal)
                self.expandButton.layoutIfNeeded()
            }
        }
    }
    
    //MARK: My IBActions
    @IBAction func expandButtonTapped(sender: UIButton) {
        self.delegate.allSearchFooterCell(cell: self, expandButtonTapped: sender)
    }
    
}
