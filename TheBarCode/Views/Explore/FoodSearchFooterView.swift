//
//  FoodSearchFooterView.swift
//  TheBarCode
//
//  Created by Mac OS X on 22/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol FoodSearchFooterViewDelegate: class {
    func foodSearchFooterView(footerView: FoodSearchFooterView, showResultsButtonTapped sender: UIButton)
}

class FoodSearchFooterView: UITableViewHeaderFooterView, NibReusable {

    @IBOutlet var resultsButton: UIButton!
    var section: Int!
    
    weak var delegate: FoodSearchFooterViewDelegate!
    
    func setupFooterView(searchResult: ScopeSearchResult) {
        if searchResult.isExpanded {
            UIView.performWithoutAnimation {
                self.resultsButton.setTitle("View Less Results", for: .normal)
                self.resultsButton.layoutIfNeeded()
            }
        } else {
            UIView.performWithoutAnimation {
                self.resultsButton.setTitle("View All Results", for: .normal)
                self.resultsButton.layoutIfNeeded()
            }
        }
    }
    
    //MARK: My IBActions
    @IBAction func viewAllResultsButtonTapped(sender: UIButton) {
        self.delegate.foodSearchFooterView(footerView: self, showResultsButtonTapped: sender)
    }

}
