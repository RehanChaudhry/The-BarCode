//
//  AddressTableViewCell.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 07/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol AddressTableViewCellDelegate: class {
    func addressTableViewCell(cell: AddressTableViewCell, editButtonTapped sender: UIButton)
    func addressTableViewCell(cell: AddressTableViewCell, deleteButtonTapped sender: UIButton)
}

class AddressTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    weak var delegate: AddressTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(address: Address) {
        self.titleLabel.text = address.label
        
        let attributedSubtitle = NSMutableAttributedString()
        
        let normalAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedAddress = NSAttributedString(string: address.address, attributes: normalAttributes)
        
        attributedSubtitle.append(attributedAddress)
        
        let italicAttributes = [NSAttributedString.Key.font : UIFont.appItalicFontOf(size: 14.0),
                                NSAttributedString.Key.foregroundColor : UIColor.white]
        let attributedCity = NSAttributedString(string: "\n" + address.city, attributes: italicAttributes)
        
        attributedSubtitle.append(attributedCity)
        
        if address.additionalInfo.count > 0 {
            let infottributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                    NSAttributedString.Key.foregroundColor : UIColor.appGrayColor()]
            let attribtuedInfo = NSAttributedString(string: "\nNote: " + address.additionalInfo, attributes: infottributes)
            attributedSubtitle.append(attribtuedInfo)
        }
        
        self.subTitleLabel.attributedText = attributedSubtitle
    }
    
    //MARK: My IBActions
    @IBAction func editButtonTapped(sender: UIButton) {
        self.delegate?.addressTableViewCell(cell: self, editButtonTapped: sender)
    }
    
    @IBAction func deleteButtonTapped(sender: UIButton) {
        self.delegate?.addressTableViewCell(cell: self, deleteButtonTapped: sender)
    }
    
}
