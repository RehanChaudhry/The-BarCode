//
//  MapPinCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 24/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class MapPinCell: UITableViewCell, NibReusable {
    
    @IBOutlet var offerImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.separatorInset = UIEdgeInsets(top: 0.0, left: 68.0, bottom: 0.0, right: 0.0)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(mapBar: MapBasicBar) {
        self.titleLabel.text = mapBar.title
        self.offerImageView.image = Utility.shared.getMapBarPinImage(mapBar: mapBar)
    }
    
    
}
