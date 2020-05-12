//
//  NotificationTVC.swift
//  TheBarCode
//
//  Created by Macbook on 07/05/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class NotificationTableViewCell: UITableViewCell, NibReusable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpCell(notification: NotificationItem) {
        self.titleLabel.text = notification.title
        self.descLabel.text = notification.message
        self.timeLabel.text = notification.createdAtDate.timeAgoSinceDate(numericDates: true)
    }
}



