//
//  EventCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class EventCell: UITableViewCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: My Methods
    func setupCell(event: Event) {
        self.titleLabel.text = event.name.value
        self.detailLabel.text = event.formattedDateString
        
        let url = URL(string: event.image.value)
        self.coverImageView.setImageWith(url: url, showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image")
            , shouldShowAcitivityIndicator: true, shouldShowProgress: false)
    }
}
