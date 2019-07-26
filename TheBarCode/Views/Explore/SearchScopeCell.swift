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
    }

    //MARK: My Methods
    func setupCell(searchScope: SearchScopeItem, tempViewBGColor: UIColor) {
        UIView.performWithoutAnimation {
            self.button.setTitle(searchScope.title, for: .normal)
            self.button.layoutIfNeeded()
        }
        
        if searchScope.isSelected {
            self.button.backgroundColor = UIColor.black
            self.button.tintColor = UIColor.appBlueColor()
            self.button.setTitleColor(UIColor.appBlueColor(), for: .normal)
            
        } else {
            self.button.backgroundColor = tempViewBGColor
            self.button.tintColor = UIColor.appGrayColor()
            self.button.setTitleColor(UIColor.appGrayColor(), for: .normal)
        }
    }
    
    //MARK: My IBActions
    @IBAction func scopeButtonTapped(sender: UIButton) {
        self.delegate.searchScopeCell(cell: self, scopeButtonTapped: sender)
    }
    
}
