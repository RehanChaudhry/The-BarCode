//
//  SocialLinksCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/05/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol SocialLinksCellDelegate: class {
    func socialLinksCell(cell: SocialLinksCell, facebookButtonTapped sender: UIButton)
    func socialLinksCell(cell: SocialLinksCell, twitterButtonTapped sender: UIButton)
    func socialLinksCell(cell: SocialLinksCell, instagramButtonTapped sender: UIButton)
}

class SocialLinksCell: UITableViewCell, NibReusable {

    @IBOutlet var stackView: UIStackView!
    
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var instagramButton: UIButton!
    
    weak var delegate: SocialLinksCellDelegate?
    
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
    
    func setupCell(bar: Explore) {
        
        for view in self.stackView.subviews {
            view.removeFromSuperview()
        }
        
        for view in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(view)
        }
        
        if let facebookLink = bar.facebookPageUrl.value, facebookLink.count > 0 {
            self.stackView.addArrangedSubview(self.facebookButton)
        }
        
        if let twitterLink = bar.twitterProfileUrl.value, twitterLink.count > 0 {
            self.stackView.addArrangedSubview(self.twitterButton)
        }
        
        if let instagramLink = bar.instagramProfileUrl.value, instagramLink.count > 0 {
            self.stackView.addArrangedSubview(self.instagramButton)
        }
    }
    
    //MARK: My IBActions
    @IBAction func facebookButtonTapped(sender: UIButton) {
        self.delegate?.socialLinksCell(cell: self, facebookButtonTapped: sender)
    }
    
    @IBAction func twitterButtonTapped(sender: UIButton) {
        self.delegate?.socialLinksCell(cell: self, twitterButtonTapped: sender)
    }
    
    @IBAction func instagramButtonTapped(sender: UIButton) {
        self.delegate?.socialLinksCell(cell: self, instagramButtonTapped: sender)
    }
}
