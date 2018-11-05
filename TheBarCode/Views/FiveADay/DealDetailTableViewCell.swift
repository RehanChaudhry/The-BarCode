//
//  DealDetailTableViewCell.swift
//  TheBarCode
//
//  Created by Aasna Islam on 08/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol DealDetailTableViewCellDelegate: class {
    func dealDetailCell(cell: DealDetailTableViewCell, viewBarDetailButtonTapped sender: UIButton)
    func dealDetailCell(cell: DealDetailTableViewCell, viewDirectionButtonTapped sender: UIButton)
}

class DealDetailTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var subTitleButton: UIButton!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var barNameButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    
    weak var delegate : DealDetailTableViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configCell(deal: FiveADayDeal) {
        
        self.titleButton.setTitle(deal.title.value, for: .normal)
        self.subTitleButton.setTitle(deal.subTitle.value, for: .normal)
        self.detailLabel.text =  deal.detail.value
        self.barNameButton.setTitle(deal.establishment.value!.title.value, for: .normal)
       
        if let distance = deal.establishment.value?.distance {
            self.locationLabel.isHidden = false
            self.locationLabel.text = Utility.shared.getformattedDistance(distance: distance.value)
        } else {
            self.locationLabel.isHidden = true
        }
    }

    //MARK IBActions
    @IBAction func viewBarDetailButtonTapped(_ sender: UIButton) {
        self.delegate.dealDetailCell(cell: self, viewBarDetailButtonTapped: sender)
    }
    
    @IBAction func viewDirectionButtonTapped(_ sender: UIButton) {
        self.delegate.dealDetailCell(cell: self, viewDirectionButtonTapped: sender)
    }
}
