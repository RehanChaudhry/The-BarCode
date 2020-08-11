//
//  BarAboutTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 11/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol BarAboutTableViewCellDelegate: class {
    func barAboutTableViewCell(cell: BarAboutTableViewCell, reserveTableButtonTapped sender: UIButton)
}

class BarAboutTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var detailLabel: UILabel!
    
    weak var delegate: BarAboutTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(bar: Bar) {
        self.detailLabel.text = bar.detail.value
    }
    
    //MARK: My IBActions
    @IBAction func reserveTableButtonTapped(sender: UIButton) {
        self.delegate?.barAboutTableViewCell(cell: self, reserveTableButtonTapped: sender)
    }
}
