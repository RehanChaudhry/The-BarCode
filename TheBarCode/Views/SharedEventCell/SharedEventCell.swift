//
//  SharedEventCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 01/11/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import Reusable

protocol SharedEventCellDelegate: class {
    func sharedEventCell(cell: SharedEventCell, shareButtonTapped sender: UIButton)
    func sharedEventCell(cell: SharedEventCell, bookmarkButtonTapped sender: UIButton)
    func sharedEventCell(cell: SharedEventCell, barButtonTapped sender: UIButton)
}

class SharedEventCell: MGSwipeTableCell, NibReusable {

    @IBOutlet var coverImageView: AsyncImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var barTitleButton: UIButton!
    @IBOutlet var sharedByLabel: UILabel!
    
    @IBOutlet var shareButtonContainer: ShadowView!
    @IBOutlet var shareButton: UIButton!
    @IBOutlet var sharingLoader: UIActivityIndicatorView!
    
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var bookmarkLoader: UIActivityIndicatorView!
    
    weak var sharingDelegate : SharedEventCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        
        self.coverImageView.layer.cornerRadius = 8.0
        
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(event: Event) {
        
        self.titleLabel.text = event.name.value
        
        self.barTitleButton.setTitle(event.bar.value?.title.value ?? "", for: .normal)
        
        let url = event.image.value
        self.coverImageView.setImageWith(url: URL(string: url), showRetryButton: false, placeHolder: UIImage(named: "bar_cover_image"), shouldShowAcitivityIndicator: true, shouldShowProgress: false)
        self.sharedByLabel.attributedText =  self.attributedString(prefixText: "Shared by: ", Text:  event.sharedByName.value ?? "")
        
        if event.showSharingLoader {
            self.sharingLoader.startAnimating()
            self.shareButton.isHidden = true
        } else {
            self.sharingLoader.stopAnimating()
            self.shareButton.isHidden = false
        }
        
        if event.savingBookmarkStatus {
            self.bookmarkButton.isHidden = true
            self.bookmarkLoader.startAnimating()
        } else {
            if event.isBookmarked.value {
                self.bookmarkButton.tintColor = UIColor.appBlueColor()
            } else {
                self.bookmarkButton.tintColor = UIColor.appGrayColor()
            }
            self.bookmarkLoader.stopAnimating()
            self.bookmarkButton.isHidden = false
        }
    }
    
    func attributedString(prefixText: String, Text: String) -> NSMutableAttributedString {
        let placeholderAttributes = [NSAttributedStringKey.font : UIFont.appRegularFontOf(size: 14.0),
                                     NSAttributedStringKey.foregroundColor : UIColor.white]
        let nameAttributes = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14.0),
                              NSAttributedStringKey.foregroundColor : UIColor.appBlueColor()]
        
        let placeholderAttributedString = NSMutableAttributedString(string: prefixText, attributes: placeholderAttributes)
        let nameAttributedString = NSMutableAttributedString(string: Text, attributes: nameAttributes)
        
        let finalAttributedString = NSMutableAttributedString()
        finalAttributedString.append(placeholderAttributedString)
        finalAttributedString.append(nameAttributedString)
        return finalAttributedString
        
    }
    
    //MARK: My IBActions
    @IBAction func shareButtonTapped(sender: UIButton) {
        self.sharingDelegate.sharedEventCell(cell: self, shareButtonTapped: sender)
    }
    
    @IBAction func bookmarkButtonTapped(sender: UIButton) {
        self.sharingDelegate.sharedEventCell(cell: self, bookmarkButtonTapped: sender)
    }
    
    @IBAction func barNameButtonTapped(_ sender: UIButton) {
        self.sharingDelegate.sharedEventCell(cell: self, barButtonTapped: sender)
    }
}
