//
//  SearchScopeCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol SearchScopeCellDelegate: class {
    func searchScopeCell(cell: SearchScopeCell, scopeButtonTapped sender: UIButton)
}

class SearchScopeCell: UICollectionViewCell, NibReusable {

    @IBOutlet var button: UIButton!
    
    weak var delegate: SearchScopeCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.button.titleLabel?.numberOfLines = 0
        self.button.titleLabel?.textAlignment = .center
    }

    //MARK: My Methods
    func setupCell(searchScope: SearchScopeItem, tempViewBGColor: UIColor) {
        UIView.performWithoutAnimation {
            self.button.setTitle(searchScope.title, for: .normal)
            self.button.layoutIfNeeded()
        }
        
        if searchScope.isSelected {
            if searchScope.scopeType == .all {
                self.button.backgroundColor = searchScope.selectedBackgroundColor
                self.button.tintColor = UIColor.appBlueColor()
                self.button.setTitleColor(UIColor.appBlueColor(), for: .normal)
            } else {
                self.button.backgroundColor = searchScope.selectedBackgroundColor
                self.button.tintColor = UIColor.black
                self.button.setTitleColor(UIColor.black, for: .normal)
            }
        } else {
            if searchScope.scopeType == .all {
                self.button.backgroundColor = tempViewBGColor
                self.button.tintColor = UIColor.white
                self.button.setTitleColor(UIColor.white, for: .normal)
            } else {
                self.button.backgroundColor = searchScope.backgroundColor
                self.button.tintColor = UIColor.black
                self.button.setTitleColor(UIColor.black, for: .normal)
            }
        }
    }
    
    //MARK: My IBActions
    @IBAction func scopeButtonTapped(sender: UIButton) {
        self.delegate.searchScopeCell(cell: self, scopeButtonTapped: sender)
    }
    
}
