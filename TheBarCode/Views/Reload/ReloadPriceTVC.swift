//
//  reloadPriceTVC.swift
//  TheBarCode
//
//  Created by Aasna Islam on 30/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import StoreKit

class ReloadPriceTVC: UITableViewCell, NibReusable {

    @IBOutlet weak var detailLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(state: ReloadState, product: SKProduct) {
        
        if state == ReloadState.noOfferRedeemed {
                        
            let font = UIFont.appRegularFontOf(size: 15.0)
            let boldAttributes = [NSAttributedStringKey.font: font,
                                  NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let description = "You can reload all offers when the counter hits 0:00:00:00 Invite friends and share the offers you receive to earn more credits."
            let attributedText = NSAttributedString(string: description, attributes: boldAttributes)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedText)
            
            self.detailLabel.attributedText = finalAttributedString

        } else if state == ReloadState.offerRedeemed {
           
            let font = UIFont.appRegularFontOf(size: 15.0)
            let boldAttributes = [NSAttributedStringKey.font: font,
                                  NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let description = "In the meantime you can use credits to top up offers or unlock venues you have redeemed at already"
            let attributedText = NSAttributedString(string: description, attributes: boldAttributes)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedText)
            
            self.detailLabel.attributedText = finalAttributedString

        } else if state == ReloadState.reloadTimerExpire {
                        
            let font = UIFont.appRegularFontOf(size: 48.0)
            let fontBold = UIFont.appBoldFontOf(size: 15.0)
            
            let boldAttributes = [NSAttributedStringKey.font: fontBold,
                                  NSAttributedStringKey.foregroundColor: UIColor.white]
            
            let blueAttributes = [NSAttributedStringKey.font: font,
                                  NSAttributedStringKey.foregroundColor: UIColor.appBlueColor()]
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = product.priceLocale
            let cost = formatter.string(from: product.price) ?? ""
            
            let description = "Reload all offers \n& access credits for \n "
            let description2 = cost

            let attributedText = NSAttributedString(string: description, attributes: boldAttributes)
            let attributedPrice = NSAttributedString(string: description2, attributes: blueAttributes)
            
            let finalAttributedString = NSMutableAttributedString()
            finalAttributedString.append(attributedText)
            finalAttributedString.append(attributedPrice)
            
            self.detailLabel.attributedText = finalAttributedString
            
        }
    }

}
