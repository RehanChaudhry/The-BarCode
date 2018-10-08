//
//  DealDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 08/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class DealDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var barNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(deal: FiveADayDeal) {
        self.titleLabel.text = deal.title
        self.subTitleLabel.text = deal.subTitle
        self.detailLabel.text = deal.detail
        self.locationLabel.text = deal.distance
        self.barNameLabel.text = deal.location
    }

}
